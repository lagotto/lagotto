json.cache! ['v3', @article], skip_digest: true do
  json.(@article, :doi, :title, :url, :mendeley, :pmid, :pmcid, :publication_date, :update_date, :views, :shares, :bookmarks, :citations)

  unless params[:info] == "summary"
    json.sources @article.retrieval_statuses do |rs|
      json.cache! ['v3', rs, params[:info]], skip_digest: true do
        json.(rs, :name, :display_name, :events_url, :metrics, :update_date)
        json.events rs.events if ["detail","event"].include?(params[:info])
        json.(rs, :by_day, :by_month, :by_year) if ["detail","history"].include?(params[:info])
      end
    end
  end
end
