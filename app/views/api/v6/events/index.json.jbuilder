json.meta do
  json.status "ok"
  json.message_type "event-list"
  json.message_version "6.0.0"
  json.total @events.total_entries
  json.total_pages @events.per_page > 0 ? @events.total_pages : 1
  json.page @events.total_entries > 0 ? @events.current_page : 1
end

json.events @events do |event|
  json.cache! ['v6', event, params[:work_id]], skip_digest: true do

    json.(event.work, :id, :title, :issued, :container_title, :volume, :page, :issue, :publisher_id, :doi, :url, :pmid, :pmcid, :scp, :wos, :ark, :metrics)
    json.(event, :source_id, :event_id, :relation_type_id, :update_date)
  end
end
