require 'github/markdown'
require 'rouge'

module ApplicationHelper
  def login_link
    if ENV['CAS_URL']
      link_to "Sign In", user_omniauth_authorize_path(:cas), :id => "sign_in"
    else
      s = form_tag '/users/auth/persona/callback', :id => 'persona_form', :class => "navbar-form" do
        p = hidden_field_tag('assertion')
        p << button_tag('Sign In with Persona', :id => 'sign_in', :class => 'btn btn-link persona')
        p
      end
      s.html_safe
    end
  end

  def markdown(text)
    text = GitHub::Markdown.render_gfm(text)
    syntax_highlighter(text).html_safe
  end

  def syntax_highlighter(html)
    formatter = Rouge::Formatters::HTML.new(:css_class => 'hll')
    lexer = Rouge::Lexers::Shell.new

    doc = Nokogiri::HTML(html)
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

  def level_label(level)
    case level
    when 1 then '<span class="label label-info">Info</span>'
    when 2 then '<span class="label label-warning">Warn</span>'
    when 3 then '<span class="label label-danger">Error</span>'
    when 4 then '<span class="label label-fatal">Fatal</span>'
    else '<span class="label label-default">Other</span>'
    end
  end

  def number_hiding_zero(number)
    (number.nil? || number == 0 ? "" : number_with_delimiter(number))
  end

  def sources
    Source.order("group_id, display_name")
  end

  def publishers
    Publisher.order("name")
  end

  def alerts
    %w(Net::HTTPUnauthorized Net::HTTPForbidden Net::HTTPRequestTimeOut Net::HTTPGatewayTimeOut Net::HTTPConflict Net::HTTPServiceUnavailable - Faraday::ResourceNotFound ActiveRecord::RecordInvalid - Delayed::WorkerTimeout DelayedJobError TooManyErrorsBySourceError SourceInactiveError TooManyWorkersError - EventCountDecreasingError EventCountIncreasingTooFastError ApiResponseTooSlowError HtmlRatioTooHighError ArticleNotUpdatedError SourceNotUpdatedError CitationMilestoneAlert)
  end

  def article_statistics_report_path
    path = "/files/alm_report.zip"
    if File.exist?("#{Rails.root}/public#{path}")
      path
    else
      nil
    end
  end

  def date_format(article)
    if article.day
      :long
    elsif article.month
      :month
    else
      :year
    end
  end

  def date_from_iso8601(date)
    DateTime.parse(date).to_s(:short)
  end

  def description_with_link(report)
    if report.name == 'article_statistics_report' && article_statistics_report_path
      h(report.description) + link_to("Download", article_statistics_report_path, :class => 'pull-right')
    else
      h(report.description)
    end
  end

  def article_alerts
    %w(EventCountDecreasingError EventCountIncreasingTooFastError ApiResponseTooSlowError HtmlRatioTooHighError ArticleNotUpdatedError CitationMilestoneAlert)
  end

  def documents
    %w(Home Installation Setup Sources API Rake Alerts Releases Roadmap Contributors)
  end

  def roles
    %w(user staff admin)
  end
end
