json.ignore_nil! false

json.total @works.total_entries
json.total_pages (@works.total_entries.to_f / @works.per_page).ceil
json.page @works.total_entries > 0 ? @works.current_page : 0
json.error @error

json.data @works do |work|
  json.cache! ['v5', work], skip_digest: true do
    json.(work, :id, :title, :issued, :publisher_id, :doi, :url, :pmid, :pmcid, :scp, :wos, :ark, :viewed, :saved, :discussed, :cited, :update_date)

    if work.tracked
      json.sources work.filtered_retrieval_statuses do |rs|
        json.cache! ['v5', rs], skip_digest: true do
          json.(rs, :name, :display_name, :group_name, :events_url, :by_month, :metrics, :update_date)
        end
      end
    end
  end
end
