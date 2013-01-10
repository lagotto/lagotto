attribute :public_url  => :events_url 
node(:name) { |rs| rs.source.name }
        
# show event data from CouchDB only if :info == detail or :info == event
if ["detail","event"].include?(params[:info]) 
  attributes :events 
end
    
# show history data from CouchDB only if :info == detail or :info == history
if ["detail","history"].include?(params[:info]) 
  if params[:days]
    node(:histories) do |rs|
      rs.retrieval_histories.after_days(params[:days]).map { |rh| { :update_date => rh.updated_at.utc.iso8601, :total => rh.total } }
    end
  elsif params[:months]
    node(:histories) do |rs|
      rs.retrieval_histories.after_months(params[:months]).map { |rh| { :update_date => rh.updated_at.utc.iso8601, :total => rh.total } }
    end
  elsif params[:year]
    node(:histories) do |rs|
      rs.retrieval_histories.until_year(params[:year]).map { |rh| { :update_date => rh.updated_at.utc.iso8601, :total => rh.total } }
    end
  else
    node(:histories) do |rs| 
      rs.retrieval_histories.map { |rh| { :update_date => rh.updated_at.utc.iso8601, :total => rh.total } }
    end
  end
end
    
# metrics are formatted in the retrieval_history model via retrieval_status
node(:metrics) { |rs| rs.metrics({:days => params[:days], :months => params[:months], :year => params[:year]}) }
node(:update_date) { |rs| rs.update_date({:days => params[:days], :months => params[:months], :year => params[:year]}) }