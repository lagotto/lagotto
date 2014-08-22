object @article
cache ['v3', current_user, @article]

attributes :doi, :title, :url, :mendeley, :pmid, :pmcid, :publication_date, :update_date, :views, :shares, :bookmarks, :citations

unless params[:info] == "summary"
  child :retrieval_statuses => :sources do |rs|
    cache ['v3', rs, params[:info]]
    attributes :name, :display_name, :events_url, :metrics, :update_date

    attributes :events if ["detail","event"].include?(params[:info])
    attributes :by_day, :by_month, :by_year if ["detail","history"].include?(params[:info])
  end
end
