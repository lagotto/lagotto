class Admin::ResponsesController < Admin::ApplicationController
  
  load_and_authorize_resource :error_message, :parent => false
  
  def index
    if request.xhr?
      responses = RetrievalStatus.includes(:source).where("sources.active = 1 AND retrieved_at > NOW() - INTERVAL 24 HOUR").order("group_id, display_name").group(:source_id).count
      errors = ErrorMessage.unscoped.includes(:source).where("sources.active = 1 AND error_messages.created_at > NOW() - INTERVAL 24 HOUR").order("group_id, display_name").group(:source_id).count
      @sources = Source.active.zip(responses, errors).map { |source| { "id" => source.first.id,
                                                                       "name" => source.first.display_name, 
                                                                       "status" => source.first.status,
                                                                       "url" => admin_source_path(source.first),
                                                                       "group" => source.first.group_id, 
                                                                       "response_count" => source[1],
                                                                       "error_count" => source[2] } }
      render :partial => "index"
    else
      render :index
    end
  end

end