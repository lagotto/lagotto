class Api::IndexController < ApplicationController
  def index
    @title = 'API'
    # render "swagger_ui/swagger_ui", discovery_url: "public/api_docs.json"
  end
end
