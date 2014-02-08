collection @articles

attributes :doi, :title, :canonical_url, :mendeley_uuid, :pmid, :pmcid, :publication_date, :update_date, :views, :shares, :bookmarks, :citations

unless params[:info] == "summary"
  child :retrieval_statuses => :sources do
    attributes :name, :display_name, :events_url, :metrics, :update_date

    attributes :events if ["detail","event"].include?(params[:info])
    attributes :histories if ["detail","history"].include?(params[:info])
    attributes :histories, :by_day, :by_month, :by_year if ["detail","history"].include?(params[:info])
  end
end
