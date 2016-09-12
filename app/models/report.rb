require 'zip'
require 'slack-notifier'
require 'mailgun'

class Report < ActiveRecord::Base
  # include HTTP request helpers
  include Networkable

  has_and_belongs_to_many :users

  serialize :config, OpenStruct

  # colors for Slack messages
  LEVEL_COLORS = {
    Notification::DEBUG => "#dcdde0",
    Notification::INFO => "good",
    Notification::WARN => "warning",
    Notification::ERROR => "danger",
    Notification::FATAL => "danger"

  }
  ICON_URL = "https://raw.githubusercontent.com/lagotto/lagotto/master/public/apple-touch-icon.png"

  def self.available(role)
    if role == "user"
      where(:private => false)
    else
      all
    end
  end

  def interval
    config.interval || 1.day
  end

  def interval=(value)
    config.interval = value.to_i
  end

  # Reports are sent via ActiveJob
  # Supports sending reports to mailgun, slack, and/or webhook

  def send_report(template, options={})
    options[:title] ||= "#{ENV['SITE_TITLE']} Report"
    options[:level] ||= Notification::INFO
    options[:link] ||= ENV['SERVER_URL'] + "/notifications"

    result = []
    result << send_report_to_mailgun(template, options) if ENV['MAILGUN_API_KEY'].present?
    result << send_report_to_slack(template, options) if ENV['SLACK_WEBHOOK_URL'].present?
    result << send_report_to_webhook(template, options) if ENV['WEBHOOK_URL'].present?
  end

  def send_report_to_mailgun(template, options={})
    if ENV['JWT_HOST'].present?
      return nil unless ENV['REPORT_EMAIL'].present?
      to = ENV['REPORT_EMAIL']
    else
      return nil if report.users.empty?
      to = report.users.map(&:email).join(",")
    end

    return nil unless ENV['MAILGUN_API_KEY'].present? &&
                      ENV['MAILGUN_DOMAIN'].present? &&
                      ENV['ADMIN_EMAIL'].present?

    text = render_template(template + '.text.erb', options).to_str
    html = render_template(template + '.html.erb', options).to_str

    message_params = {
      from: ENV['ADMIN_EMAIL'],
      to: to,
      subject: "[#{ENV['SITE_NAME']}] " + options[:title],
      text: text,
      html: html
    }

    notifier = Mailgun::Client.new ENV['MAILGUN_API_KEY']
    response = notifier.send_message ENV['MAILGUN_DOMAIN'], message_params
    JSON.parse(response.body)
  end

  def send_report_to_slack(template, options={})
    return nil unless ENV['SLACK_WEBHOOK_URL'].present?

    text = render_template(template + '.md.erb', options).to_str

    attachment = {
      title: options[:title],
      title_link: options[:link],
      text: text,
      color: LEVEL_COLORS.fetch(options[:level], "#dcdde0")
    }

    notifier = Slack::Notifier.new ENV['SLACK_WEBHOOK_URL'],
                                   username: ENV['SITE_NAME'],
                                   icon_url: ICON_URL
    response = notifier.ping attachments: [attachment]
    response.body
  end

  def send_report_to_webhook(template, options={})
    return nil unless ENV['WEBHOOK_URL'].present?

    text = render_template(template + '.html.erb', options).to_str

    data = { "title" => options[:title],
             "text" => text,
             "level" => options[:level],
             "timestamp" => Time.zone.now.utc.iso8601 }
    get_result(ENV['WEBHOOK_URL'], data: data.to_json, token: ENV['API_KEY'])
  end

  def send_error_report
    reviews = Review.daily_report.to_a
    return nil unless reviews.present?

    ReportJob.perform_later(self, __method__.to_s,
                            reviews: reviews,
                            title: "Error Report",
                            link: ENV['SERVER_URL'] + "/notifications",
                            level: Notification::ERROR)
  end

  def send_status_report
    ReportJob.perform_later(self, __method__.to_s,
                            status: Status.first_or_create,
                            title: "Status Report",
                            link: ENV['SERVER_URL'] + "/status",
                            level: Notification::INFO)
  end

  def send_work_statistics_report
    ReportJob.perform_later(self, __method__.to_s,
                            status: Status.first_or_create,
                            title: "Work Statistics Report",
                            link: ENV['SERVER_URL'] + "/status",
                            level: Notification::INFO)
  end

  def send_fatal_error_report(message)
    return nil unless message.present?

    ReportJob.perform_later(self, __method__.to_s,
                            message: message,
                            title: "Fatal Error Report",
                            link:  ENV['SERVER_URL'] + "/notifications?level=fatal",
                            level: Notification::FATAL)
  end

  def send_stale_source_report(source_ids)
    sources = Source.where(id: source_ids).to_a
    return nil unless sources.present?

    ReportJob.perform_later(self, __method__.to_s,
                            sources: sources,
                            title: "Stale Source Report",
                            link: ENV['SERVER_URL'] + "/notifications?class=SourceNotUpdatedError",
                            level: Notification::WARN)
  end

  # render erb template similar to action_mailer
  def render_template(template, params)
    ApplicationController.render(
      template: "report_templates/#{template}",
      assigns: params,
      layout: false
    )
  end
end
