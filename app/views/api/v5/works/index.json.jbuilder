json.ignore_nil! false

json.total @works.total_entries
json.total_pages (@works.total_entries.to_f / @works.per_page).ceil
json.page @works.total_entries > 0 ? @works.current_page : 0
json.error @error

json.data @works do |work|
  json.cache! ['v5', work], skip_digest: true do
    json.(work, :id, :title, :issued, :publisher_id, :doi, :url, :pmid, :pmcid, :scp, :wos, :ark, :viewed, :saved, :discussed, :cited, :update_date)

    if params[:info] != "summary" && work.tracked
      json.sources work.filtered_events do |rs|
        json.cache! ['v5', rs, params[:info]], skip_digest: true do
          json.(rs, :name, :display_name, :group_name, :events_url, :by_month, :by_year, :metrics, :update_date)
          json.events rs.events if params[:info] == "detail"
        end
      end
    end
  end
end
