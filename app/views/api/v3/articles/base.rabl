attributes :doi, :title, :url, :mendeley
attribute :pub_med => :pmid
attribute :pub_med_central => :pmcid

node(:publication_date) { |article| article.published_on.nil? ? nil : article.published_on.to_time.utc.iso8601 }

unless params[:info] == "summary"
  child :retrieval_statuses  => :sources do
    # show event and history data from CouchDB only if :info == detail
    if params[:info] == "detail"
      attributes :events 
      if params[:days]
        node(:histories) do |rs|
          rs.retrieval_histories.after_days(params[:days]).map { |rh| { :update_date => rh.updated_at.utc.iso8601, :count => rh.event_count } }
        end
      elsif params[:months]
        node(:histories) do |rs|
          rs.retrieval_histories.after_months(params[:months]).map { |rh| { :update_date => rh.updated_at.utc.iso8601, :count => rh.event_count } }
        end
      else
        node(:histories) do |rs| 
          rs.retrieval_histories.map { |rh| { :update_date => rh.updated_at.utc.iso8601, :count => rh.event_count } }
        end
      end
    end
    # metrics are formatted in the retrieval_history model via retrieval_status
    node(:metrics) { |rs| rs.metrics({:days => params[:days], :months => params[:months]}) }
    attribute :public_url  => :events_url 
  
    node(:name) { |rs| rs.source.name }
    node(:update_date) { |rs| rs.updated_at.utc.iso8601 }
  end
end