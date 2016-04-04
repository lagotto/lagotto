json.meta do
  json.status "ok"
  json.set! :"message-type", "source"
  json.set! :"message-version", "v7"
end

json.source do
  json.cache! ['v7', @source], skip_digest: true do
    json.(@source, :id, :title, :group_id, :description, :state, :timestamp)
    if @source.group.name != "other"
      json.(@source, :work_count, :relation_count, :event_count, :by_day, :by_month)
    end
  end
end
