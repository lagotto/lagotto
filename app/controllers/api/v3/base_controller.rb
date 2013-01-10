class Api::V3::BaseController < ActionController::Base 
   
  respond_to :json, :xml, :only => [ :index, :show ]
  
  before_filter :default_format_json

  def default_format_json
    request.format = :json if request.format.html?
  end

end