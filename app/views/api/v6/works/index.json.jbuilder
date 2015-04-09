json.meta do
  json.status "ok"
  json.message_type "work-list"
  json.message_version "6.0.0"
  json.total @works.total_entries
  json.total_pages @works.per_page > 0 ? @works.total_pages : 1
  json.page @works.total_entries > 0 ? @works.current_page : 1
end

json.works @works do |work|
  json.cache! ['v6', work], skip_digest: true do
    json.(work, :id, :title, :issued, :container_title, :volume, :page, :issue, :publisher_id, :doi, :url, :pmid, :pmcid, :scp, :wos, :ark, :metrics, :update_date)
  end
end
