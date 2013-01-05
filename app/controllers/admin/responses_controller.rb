class Admin::ResponsesController < Admin::ApplicationController
  
  def index
    @sources = Source.includes(:retrieval_histories).order("name")
    respond_with @sources
  end

end