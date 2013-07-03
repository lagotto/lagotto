class Admin::ResponsesController < Admin::ApplicationController
  
  authorize_resource :class => false
  
  def index
    if request.xhr?
      responses = RetrievalStatus.joins(:source).where("sources.active = 1 AND retrieved_at > NOW() - INTERVAL 24 HOUR").order("group_id, display_name").group(:source_id).count
      errors = ErrorMessage.unscoped.joins(:source).where("sources.active = 1 AND error_messages.created_at > NOW() - INTERVAL 24 HOUR AND sources.active = 1").order("group_id, display_name").group(:source_id).count
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