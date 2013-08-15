class ErrorMessagesController < ActionController::Base
  layout APP_CONFIG['layout']
  
  respond_to :html, :xml, :json

  def create
    exception = env["action_dispatch.exception"]
    @error_message = ErrorMessage.new(:exception => exception, :request => request)
    
    # Filter for errors that should not be saved
    unless["ActiveRecord::RecordNotFound","ActionController::RoutingError"].include?(exception.class.to_s)
      @error_message.save 
    else
      @error_message.status = request.headers["PATH_INFO"][1..-1]
    end
    
    respond_with(@error_message) do |format|
      format.json { render json: { error: @error_message.public_message }, status: @error_message.status }
      format.xml  { render xml: @error_message.public_message, root: "error", status: @error_message.status }
      format.html { render :show, status: @error_message.status, layout: !request.xhr? }
    end
  end

end