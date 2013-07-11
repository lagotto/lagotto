class Admin::ResponsesController < Admin::ApplicationController
  
  load_and_authorize_resource :error_message, :parent => false
  
  def index
    if request.xhr?
      responses = RetrievalStatus.includes(:source).where("sources.active = 1 AND retrieved_at > NOW() - INTERVAL 24 HOUR").order("group_id, display_name").group(:source_id).count
      errors = ErrorMessage.unscoped.includes(:source).where("sources.active = 1 AND error_messages.created_at > NOW() - INTERVAL 24 HOUR").order("group_id, display_name").group(:source_id).count
      @sources = Source.active.map { |source| { "id" => source.id,
                                                "name" => source.display_name, 
                                                "status" => source.status,
                                                "url" => admin_source_path(source),
                                                "group" => source.group_id, 
                                                "response_count" => responses[source.id],
                                                "error_count" => errors[source.id] }}
      render :partial => "index"
    else
      render :index
    end
  end

end