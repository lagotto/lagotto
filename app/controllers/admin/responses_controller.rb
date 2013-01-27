class Admin::ResponsesController < Admin::ApplicationController
  
  def index
    @sources = Source.active
    @responses_count = RetrievalStatus.joins(:source).where("retrieved_at > NOW() - INTERVAL 24 HOUR").group(:source_id).count
    @errors_count = ErrorMessage.unscoped.joins(:source).where("error_messages.created_at > NOW() - INTERVAL 24 HOUR").order("group_id, display_name").group(:source_id).count
    respond_with @sources
  end

end