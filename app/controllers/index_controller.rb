class IndexController < ApplicationController
  def index
    meta = { meta: { name: ENV['SITE_TITLE'] }}.to_json
    render json: meta
  end
end
