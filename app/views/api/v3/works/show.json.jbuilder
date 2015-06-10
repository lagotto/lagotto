json.ignore_nil! false

if ENV["API"] == "rabl"
  json.array! @works do |work|
    json.cache! ['v3', work], skip_digest: true do
      json.(work, :doi, :title, :url, :mendeley, :pmid, :pmcid, :publication_date, :update_date, :views, :shares, :bookmarks, :citations)

      unless params[:info] == "summary"
        json.sources work.retrieval_statuses do |rs|
          json.cache! ['v3', rs, params[:info]], skip_digest: true do
            json.(rs, :name, :display_name, :events_url, :metrics, :update_date)
            json.events rs.events if ["detail","event"].include?(params[:info])
            json.(rs, :by_day, :by_month, :by_year) if ["detail","history"].include?(params[:info])
          end
        end
      end
    end
  end
else
  json.cache! ['v3', @work], skip_digest: true do
    json.(@work, :doi, :title, :url, :mendeley, :pmid, :pmcid, :publication_date, :update_date, :views, :shares, :bookmarks, :citations)

    unless params[:info] == "summary"
      json.sources @work.retrieval_statuses do |rs|
        json.cache! ['v3', rs, params[:info]], skip_digest: true do
          json.(rs, :name, :display_name, :events_url, :metrics, :update_date)
          json.events rs.events if ["detail","event"].include?(params[:info])
          json.(rs, :by_day, :by_month, :by_year) if ["detail","history"].include?(params[:info])
        end
      end
    end
  end
end
