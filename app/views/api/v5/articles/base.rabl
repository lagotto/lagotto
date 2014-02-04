collection @articles
cache @articles

attributes :doi, :title, :url, :mendeley, :pmid, :pmcid, :publication_date, :update_date, :viewed, :saved, :discussed, :cited

unless params[:info] == "summary"
  child :retrieval_statuses => :sources do
    attributes :name, :display_name, :group_name, :events_url, :metrics, :update_date

    attributes :events if ["detail","event"].include?(params[:info])
    attributes :histories if ["detail","history"].include?(params[:info])
    attributes :histories, :by_day, :by_month, :by_year if ["detail","history"].include?(params[:info])
  end
end