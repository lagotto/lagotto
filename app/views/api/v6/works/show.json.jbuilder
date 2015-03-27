json.success @success
json.error nil

json.work do
  json.(@work, :id, :doi, :title, :issued, :publisher_id, :canonical_url, :pmid, :pmcid, :scp, :wos, :ark, :viewed, :saved, :discussed, :cited, :update_date)

  unless params[:info] == "summary"
    json.sources @work.retrieval_statuses do |rs|
      json.(rs, :name, :title, :group_name, :events_url, :by_day, :by_month, :by_year, :update_date)
      json.metrics rs.new_metrics
      json.events rs.events if params[:info] == "detail"
    end
  end
end
