require 'cgi'

class OembedController < ApplicationController
  respond_to :json, :xml

  def show
    url = CGI.unescape(params[:url])
    url = Rails.application.routes.recognize_path(url)

    # proceed if url was recognized
    if url["action"] != "routing_error"
      id_hash = Article.from_uri(url[:id])
      article = Article.joins(:sources).where(id_hash).first
    end

    # proceed if article was found
    if url["action"] != "routing_error" && article.present?
      @article = article.decorate(context: { maxwidth: params[:maxwidth], maxheight: params[:maxheight] })
    else
      render :template => "oembed/not_found", :status => :not_found
    end
  end
end
