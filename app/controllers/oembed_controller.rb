require 'cgi'

class OembedController < ApplicationController
  respond_to :json, :xml

  def show
    url = CGI.unescape(params[:url])
    url = Rails.application.routes.recognize_path(url)
    id_hash = Article.from_uri(url[:id])
    article = Article.includes(:sources).where(id_hash).first

    # raise error if article wasn't found
    fail ActiveRecord::RecordNotFound, "No record for \"#{params[:url]}\" found" if article.blank?

    @article = article.decorate(context: { maxwidth: params[:maxwidth], maxheight: params[:maxheight] })
  end
end
