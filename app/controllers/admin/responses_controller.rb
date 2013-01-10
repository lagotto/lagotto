class Admin::ResponsesController < Admin::ApplicationController
  
  def index
    @sources = Source.order("name")
    @responses_count = RetrievalHistory.where("retrieved_at > NOW() - INTERVAL 24 HOUR").group(:source_id).count
    @errors_count = RetrievalHistory.where("status = 'ERROR' AND retrieved_at > NOW() - INTERVAL 24 HOUR").group(:source_id).count
    respond_with @sources
  end

end