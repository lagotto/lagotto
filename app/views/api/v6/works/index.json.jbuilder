json.meta do
  json.total @works.total_entries
  json.total_pages (@works.total_entries.to_f / @works.per_page).ceil
  json.page @works.total_entries > 0 ? @works.current_page : 0
end

json.works @works do |work|
  json.cache! ['v6', work], skip_digest: true do
    json.(work, :id, :title, :issued, :container_title, :volume, :page, :issue, :publisher_id, :doi, :url, :pmid, :pmcid, :scp, :wos, :ark, :viewed, :saved, :discussed, :cited, :update_date)

    if params[:info] != "summary" && work.tracked
      json.metrics work.filtered_retrieval_statuses do |rs|
        json.cache! ['v6', rs, params[:info]], skip_digest: true do
          json.(rs, :name, :events_url, :pdf, :html, :readers, :comments, :likes, :total, :by_day, :by_month, :by_year, :update_date)
        end
      end
      json.(work, :events) if params[:info] == "detail"
    else
      json.metrics []
    end
  end
end
