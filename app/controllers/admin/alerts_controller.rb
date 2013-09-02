class Admin::ErrorMessagesController < Admin::ApplicationController

  load_and_authorize_resource

  def index
    collection = ErrorMessage
    if params[:source_id]
      collection = collection.where(:source_id => params[:source_id])
      @source = Source.find(params[:source_id])
    end
    collection = collection.query(params[:query]) if params[:query]

    @error_messages = collection.paginate(:page => params[:page])
    respond_with @error_messages
  end

  def destroy
    @error_message = ErrorMessage.find(params[:id])
    if params[:filter] == "class_name"
      ErrorMessage.where(:class_name => @error_message.class_name).update_all(:unresolved => false)
    elsif params[:filter] == "source_id"
      ErrorMessage.where(:source_id => @error_message.source_id).update_all(:unresolved => false)
    else
      ErrorMessage.where(:message => @error_message.message).update_all(:unresolved => false)
    end

    collection = ErrorMessage
    if params[:source_id]
      collection = collection.where(:source_id => params[:source_id])
      @source = Source.find(params[:source_id])
    end
    collection = collection.query(params[:query]) if params[:query]

    @error_messages = collection.paginate(:page => params[:page])
    respond_with(@error_messages) do |format|
      format.js { render :index }
    end
  end

end
