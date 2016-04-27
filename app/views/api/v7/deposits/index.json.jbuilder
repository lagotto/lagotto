json.meta do
  json.status "ok"
  json.set! :"message-type", "deposit-list"
  json.set! :"message-version", "v7"
  json.total @deposits.total_entries
  json.total_pages @deposits.per_page > 0 ? @deposits.total_pages : 1
  json.page @deposits.total_entries > 0 ? @deposits.current_page : 1
end

json.deposits @deposits do |deposit|
  json.cache! ['v7', deposit], skip_digest: true do
    json.(deposit, :id, :state, :message_type, :message_action, :source_token, :callback, :prefix, :subj_id, :obj_id, :relation_type_id, :source_id, :publisher_id, :registration_agency_id, :total, :occurred_at, :timestamp, :subj, :obj, :errors)
  end
end
