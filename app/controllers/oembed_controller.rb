require 'cgi'

class OembedController < ApplicationController
  # include base controller methods
  include Authenticable

  before_filter :default_format_json
  respond_to :json, :xml

  def show
    url = CGI.unescape(params[:url])
    url = Rails.application.routes.recognize_path(url)

    # proceed if url was recognized
    if url["action"] != "routing_error"
      id_hash = Article.from_uri(url[:id])
      article = Article.where(id_hash)
    end

    # proceed if article was found
    if url["action"] != "routing_error" && article.first
      @article = article.first.decorate(context: { maxwidth: params[:maxwidth], maxheight: params[:maxheight] })
    else
      render :template => "oembed/not_found", :status => :not_found
    end
  end
end
