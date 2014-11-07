json.total @articles.total_entries
json.total_pages (@articles.total_entries.to_f / @articles.per_page).ceil
json.page @articles.total_entries > 0 ? @articles.current_page : 0
json.error @error

json.data @articles do |article|
  json.cache! ['v5', article], skip_digest: true do
    json.(article, :doi, :title, :issued, :canonical_url, :pmid, :pmcid, :mendeley_uuid, :viewed, :saved, :discussed, :cited, :update_date)

    unless params[:info] == "summary"
      json.sources article.filtered_retrieval_statuses do |rs|
        json.cache! ['v5', rs, params[:info]], skip_digest: true do
          json.(rs, :name, :display_name, :group_name, :events_url, :by_day, :by_month, :by_year, :update_date)
          json.metrics rs.new_metrics
          json.events rs.events_csl if params[:info] == "detail"
        end
      end
    end
  end
end
