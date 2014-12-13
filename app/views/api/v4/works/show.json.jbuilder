json.success @success
json.error nil

json.data do
  json.(@work, :doi, :title, :issued, :canonical_url, :pmid, :pmcid, :mendeley_uuid, :viewed, :saved, :discussed, :cited, :update_date)

  unless params[:info] == "summary"
    json.sources @work.retrieval_statuses do |rs|
      json.(rs, :name, :display_name, :group_name, :events_url, :by_day, :by_month, :by_year, :update_date)
      json.metrics rs.new_metrics
      json.events rs.events_csl if params[:info] == "detail"
    end
  end
end
