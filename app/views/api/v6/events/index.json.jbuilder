json.meta do
  json.status "ok"
  json.set! :"message-type", "event-list"
  json.set! :"message-version", "6.0.0"
  json.total @events.total_entries
  json.total_pages @events.per_page > 0 ? @events.total_pages : 1
  json.page @events.total_entries > 0 ? @events.current_page : 1
end

json.events @events do |event|
  json.cache! ['v6', "event", event, params[:work_id], params[:source_id], params[:relation_type_id]], skip_digest: true do
    json.(event.work, :id, :publisher_id)
    json.(event, :event_id, :source_id, :relation_type_id)
    json.(event.work, :title, :issued)
    json.set! :"container-title", event.work.container_title
    json.(event.work, :volume, :page, :issue, :DOI, :URL, :PMID, :PMCID, :scp, :wos, :ark, :metrics)
    json.(event, :timestamp)
  end
end
