require 'github/markdown'
require 'rouge'

module ApplicationHelper
  def login_link
    case ENV['OMNIAUTH']
    when "cas" then link_to "Sign in with PLOS ID", user_omniauth_authorize_path(:cas), :id => "sign_in"
    when "github" then link_to "Sign in with Github", user_omniauth_authorize_path(:github), :id => "sign_in"
    when "orcid" then link_to "Sign in with ORCID", user_omniauth_authorize_path(:orcid), :id => "sign_in"
    when "persona" then
      form_tag "/users/auth/persona/callback", id: "persona_form", class: "navbar-form" do
        hidden_field_tag('assertion') +
        button_tag("Sign in with Persona", id: "sign_in_button", class: "btn btn-link persona")
      end.html_safe
    else
      link_to "Sign in not configured", "#", :id => "sign_in"
    end
  end

  def icon(icon, text = nil, html_options = {})
    text, html_options = nil, text if text.is_a?(Hash)

    content_class = "fa fa-#{icon}"
    content_class << " #{html_options[:class]}" if html_options.key?(:class)
    html_options[:class] = content_class

    html = content_tag(:i, nil, html_options)
    html << ' ' << text.to_s unless text.blank?
    html
  end

  def markdown(text)
    text = GitHub::Markdown.render_gfm(text)
    syntax_highlighter(text).html_safe
  end

  def syntax_highlighter(html)
    formatter = Rouge::Formatters::HTML.new(:css_class => 'hll')
    lexer = Rouge::Lexers::Shell.new

    doc = Nokogiri::HTML::DocumentFragment.parse(html)
    doc.search("//pre").each { |pre| pre.replace formatter.format(lexer.lex(pre.text)) }
    doc.to_s
  end

  def state_label(state)
    case state
    when "working" then '<span class="label label-success">working</span>'
    when "inactive" then '<span class="label label-info">inactive</span>'
    when "disabled" then '<span class="label label-warning">disabled</span>'
    when "available" then '<span class="label label-default">available</span>'
    when "retired" then '<span class="label label-primary">retired</span>'
    else state
    end
  end

  def kind_label(kind)
    case kind
    when "work" then '<span class="label label-default">work</span>'
    else '<span class="label label-info">all</span>'
    end
  end

  def level_label(level)
    case level
    when 1 then '<span class="label label-info">Info</span>'
    when 2 then '<span class="label label-warning">Warn</span>'
    when 3 then '<span class="label label-danger">Error</span>'
    when 4 then '<span class="label label-fatal">Fatal</span>'
    else '<span class="label label-default">Other</span>'
    end
  end

  def worker_label(status)
    case status
    when "working" then "panel-success"
    when "waiting" then "panel-default"
    else "panel-warning"
    end
  end

  def number_hiding_zero(number)
    (number.nil? || number == 0 ? "" : number_with_delimiter(number))
  end

  def sources
    Source.order("group_id, title")
  end

  def publishers
    Publisher.order("name")
  end

  def notifications
    %w(Net::HTTPUnauthorized Net::HTTPForbidden Net::HTTPRequestTimeOut Net::HTTPGatewayTimeOut Net::HTTPConflict Net::HTTPServiceUnavailable - Faraday::ResourceNotFound ActiveRecord::RecordInvalid - Net::HTTPTooManyRequests ActiveJobError TooManyErrorsBySourceError AgentInactiveError - EventCountDecreasingError EventCountIncreasingTooFastError ApiResponseTooSlowError HtmlRatioTooHighError WorkNotUpdatedError SourceNotUpdatedError CitationMilestoneAlert)
  end

  def work_statistics_report_path
    path = "/files/alm_report.zip"
    if File.exist?("#{Rails.root}/public#{path}")
      path
    else
      nil
    end
  end

  def author_format(author)
    authors = author.map { |a| a.fetch("given", nil).to_s + " " + a.fetch("family", nil).to_s }
    case authors.length
    when 0, 1, 2 then authors.join(" & ")
    when 3, 4 then authors[0..-2].join(", ") + " & " + authors.last
    else authors[0..3].join(", ") + ", <em>et al</em>"
    end
  end

  def date_format(work)
    if work.day
      :long
    elsif work.month
      :month
    else
      :year
    end
  end

  def date_from_iso8601(date)
    DateTime.parse(date).to_s(:short)
  end

  def description_with_link(report)
    if report.name == 'work_statistics_report' && work_statistics_report_path
      h(report.description) + link_to("Download", work_statistics_report_path, :class => 'pull-right')
    else
      h(report.description)
    end
  end

  def work_notifications
    %w(EventCountDecreasingError EventCountIncreasingTooFastError ApiResponseTooSlowError HtmlRatioTooHighError WorkNotUpdatedError CitationMilestoneAlert)
  end

  def documents
    %w(Installation Deployment Setup - Sources API Rake Notifications Styleguide - Releases Roadmap Contributors)
  end

  def roles
    %w(user staff admin)
  end
end
