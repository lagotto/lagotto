json.meta do
  json.status @status || "ok"
  json.set! :"message-type", "deposit"
  json.set! :"message-version", "v7"
end

json.deposit do
  json.cache! ['v7', @deposit], skip_digest: true do
    json.(@deposit, :id, :state, :message_type, :message_action, :source_token, :callback, :prefix, :subj_id, :obj_id, :relation_type_id, :source_id, :publisher_id, :registration_agency_id, :total, :occurred_at, :timestamp, :subj, :obj, :errors)
  end
end
