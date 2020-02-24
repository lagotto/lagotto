require 'cgi'

class OembedController < ApplicationController
  before_action :default_format_json

  def show
    if params[:url]
      url = CGI.unescape(params[:url])
      url = Rails.application.routes.recognize_path(url)
    else
      url = {}
    end

    # proceed if url was recognized
    if url["action"] && url["action"] != "routing_error"
      id_hash = get_id_hash(url[:id])
      work = Work.where(id_hash)
    end

    # proceed if work was found
    if url["action"] && url["action"] != "routing_error" && work.first
      @work = work.first.decorate(context: { maxwidth: params[:maxwidth], maxheight: params[:maxheight] })
    else
      render :template => "oembed/not_found", :status => :not_found
    end
  end
end
