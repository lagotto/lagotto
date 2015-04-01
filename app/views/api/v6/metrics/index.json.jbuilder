json.meta do
  json.status "ok"
  json.message_type "metrics-list"
  json.message_version "6.0.0"
  json.total @works.total_entries
  json.total_pages (@works.total_entries.to_f / @works.per_page).ceil
  json.page @works.total_entries > 0 ? @works.current_page : 0
  json.error @error
end

json.works @works do |work|
  json.cache! ['v5', work], skip_digest: true do
    json.(work, :id, :issued, :update_date)

    if work.tracked
      json.sources work.filtered_retrieval_statuses do |rs|
        json.cache! ['v5', rs, params[:info]], skip_digest: true do
          json.(rs, :name, :display_name, :group_name, :events_url, :by_day, :by_month, :by_year, :metrics, :update_date)
          json.events rs.events if params[:info] == "detail"
        end
      end
    end
  end
end
