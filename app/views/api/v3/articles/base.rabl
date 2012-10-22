attributes :doi, :title, :url, :mendeley
attribute :pub_med => :pmid
attribute :pub_med_central => :pmcid

node(:publication_date) { |article| article.published_on.nil? ? nil : article.published_on.to_time.utc.iso8601 }

unless params[:info] == "summary"
  child :retrieval_statuses  => :sources do
    attribute :public_url  => :events_url 
    node(:name) { |rs| rs.source.name }
        
    # show event and history data from CouchDB only if :info == detail
    if params[:info] == "detail"
      attributes :events 
      if params[:days]
        node(:histories) do |rs|
          rs.retrieval_histories.after_days(params[:days]).map { |rh| { :update_date => rh.updated_at.utc.iso8601, :total => rh.total } }
        end
      elsif params[:months]
        node(:histories) do |rs|
          rs.retrieval_histories.after_months(params[:months]).map { |rh| { :update_date => rh.updated_at.utc.iso8601, :total => rh.total } }
        end
      else
        node(:histories) do |rs| 
          rs.retrieval_histories.map { |rh| { :update_date => rh.updated_at.utc.iso8601, :total => rh.total } }
        end
      end
    end
    
    # metrics are formatted in the retrieval_history model via retrieval_status
    node(:metrics) { |rs| rs.metrics({:days => params[:days], :months => params[:months]}) }
    node(:update_date) { |rs| rs.update_date({:days => params[:days], :months => params[:months]}) }
  end
end