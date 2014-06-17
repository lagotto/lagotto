attributes :doi, :title, :canonical_url, :mendeley_uuid, :pmid, :pmcid, :issued, :views, :shares, :bookmarks, :citations, :update_date

unless params[:info] == "summary"
  child :retrieval_statuses => :sources do
    attributes :name, :display_name, :group_name, :events_url, :metrics, :update_date

    attributes :events, :events_csl if ["detail","event"].include?(params[:info])
    attributes :by_day, :by_month, :by_year if ["detail","history"].include?(params[:info])
  end
end
