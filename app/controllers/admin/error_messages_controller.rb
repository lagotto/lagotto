class Admin::ErrorMessagesController < Admin::ApplicationController
  
  def index
    collection = ErrorMessage
    collection = collection.query(params[:query]) if params[:query]
    
    @error_messages = collection.paginate(:page => params[:page])
    respond_with @error_messages
  end
  
  def destroy
    @error_message = ErrorMessage.find(params[:id])
    if params[:by_class]
      ErrorMessage.destroy_all(:class_name => @error_message.class_name)
    else
      ErrorMessage.destroy_all(:message => @error_message.message)
    end
    
    collection = ErrorMessage
    collection = collection.query(params[:query]) if params[:query]
    
    @error_messages = collection.paginate(:page => params[:page])
    respond_with(@error_messages) do |format|  
      format.js { render :index }
    end
  end
  
end