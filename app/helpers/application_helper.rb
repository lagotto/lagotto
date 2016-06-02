require 'github/markdown'
require 'rouge'

module ApplicationHelper
  def login_link
    case ENV['OMNIAUTH']
    when "cas" then link_to "Sign in with PLOS ID", user_omniauth_authorize_path(:cas), :id => "sign-in", class: 'btn btn-default'
    when "jwt" then link_to "Sign in", user_omniauth_authorize_path(:jwt), :id => "sign-in", class: 'btn btn-default'
    when "github" then link_to "Sign in with Github", user_omniauth_authorize_path(:github), :id => "sign-in", class: 'btn btn-default'
    when "orcid" then link_to "Sign in with ORCID", user_omniauth_authorize_path(:orcid), :id => "sign-in", class: 'btn btn-default'
    else
      link_to "Sign in not configured", "#"
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

  def formatted_class_name(string)
    return string if string.length < 25

    string.split("::", 2).last
  end

  def states
     %w(waiting working failed done)
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

  def status_label(name, status)
    case status
    when "OK" then name
    else "<span class='label label-warning'>#{name}</span>"
    end
  end

  def number_hiding_zero(number)
    (number.nil? || number == 0 ? "" : number_with_delimiter(number))
  end

  def sources
    Source.order("group_id, title")
  end

  def publishers
    Publisher.active.order("name")
  end

  def contributors
    Contributor.order("family_name")
  end

  def author_format(author)
    author = [author] if author.is_a?(Hash)
    authors = Array(author).map do |a|
      if a.is_a?(Hash)
        name = [a.fetch("given", nil), a.fetch("family", nil)].compact.join(' ')
        if a["ORCID"].present?
          pid_short = CGI.escape(a["ORCID"].gsub(/(http|https):\/+(\w+)/, '\2'))
          "<a href=\"/contributors/#{pid_short}\">#{name}</a>"
        else
          name
        end
      else
        nil
      end
    end.compact

    fa = case authors.length
         when 0..2 then authors.join(" & ")
         when 3..20 then authors[0..-2].join(", ") + " & " + authors.last
         else authors[0..19].join(", ") + " … & " + authors.last
         end
    fa.html_safe
  end

  def metadata_format(work)
    work_type = work.work_type.present? ? work.work_type.title : "Work"
    publication_date = "published " + l(work.published_on, format: date_format(work))
    container_title = work.container_title.present? ? "via " + work.container_title : ""

    [work_type, publication_date, container_title].join(" ")
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
    if report.name == 'work_statistics_report'
      h(report.description) #+ link_to("Download", work_statistics_report_path, :class => 'pull-right')
    else
      h(report.description)
    end
  end

  def work_notifications
    %w(EventCountDecreasingError EventCountIncreasingTooFastError ApiResponseTooSlowError HtmlRatioTooHighError WorkNotUpdatedError CitationMilestoneAlert)
  end

  def documents
    %w(Installation Deployment Setup - Agents Deposits Rake Notifications Styleguide - Releases Roadmap Contributors)
  end

  def roles
    %w(user contributor staff admin)
  end

  def settings
    Settings[ENV['MODE']]
  end

  def data_tags_for_api
    data = { per_page: 15, model: controller.controller_name }
    data[:api_key] = current_user.api_key if current_user
    data[:page] = @page if @page.present?
    data[:pid] = @work.pid if @work.present?
    data[:q] = @q if @q.present?
    data[:class_name] = @class_name if @class_name.present?
    data[:publisher_id] = @publisher.name if @publisher.present?
    data[:source_id] = @source.name if @source.present?
    data[:relation_type_id] = @relation_type.name if @relation_type.present?
    data[:work_type_id] = @work_type.name if @work_type.present?
    data[:registration_agency_id] = @registration_agency.name if @registration_agency.present?
    data[:contributor_role_id] = @contributor_role.name if @contributor_role.present?
    data[:contributor_id] = @contributor.pid if @contributor.present?
    data[:sort] = @sort.name if @sort.present?
    data[:state] = states[@state] if @state.present?

    { class: "logo", id: "api_key", data: data }
  end
end
