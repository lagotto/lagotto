class ErrorMessagesController < ActionController::Base
  layout APP_CONFIG['layout']
  
  respond_to :html, :xml, :json

  def create
    @error_message = ErrorMessage.create(:exception => env["action_dispatch.exception"], :request => request, :source_id => source_id)
    
    respond_with(@error_message) do |format|
      format.json { render json: { error: @error_message.public_message }, status: @error_message.status }
      format.xml  { render xml: @error_message.public_message, root: "error", status: @error_message.status }
      format.html { render :show, status: @error_message.status, layout: !request.xhr? }
    end
  end

end