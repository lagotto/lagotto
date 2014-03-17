object @article

attributes :doi, :title, :url, :mendeley, :pmid, :pmcid, :publication_date, :update_date, :views, :shares, :bookmarks, :citations

unless params[:info] == "summary"
  child :retrieval_statuses => :sources do
    attributes :name, :display_name, :events_url, :metrics, :update_date

    attributes :events, :by_day, :by_month, :by_year if params[:info] == "detail"
  end
end