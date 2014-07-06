cache ['v4', @article]

attributes :doi, :title, :canonical_url, :mendeley_uuid, :pmid, :pmcid, :issued, :views, :shares, :bookmarks, :citations, :update_date

unless params[:info] == "summary"
  child :retrieval_statuses => :sources do
    attributes :name, :display_name, :group_name, :events_url, :by_day, :by_month, :by_year, :update_date
    attributes :new_metrics => :metrics

    attributes :events, :events_csl if params[:info] == "detail"
  end
end
