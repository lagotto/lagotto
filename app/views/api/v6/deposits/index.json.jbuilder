json.meta do
  json.status "ok"
  json.set! :"message-type", "deposit-list"
  json.set! :"message-version", "6.0.0"
  json.total @deposits.total_entries
  json.total_pages @deposits.per_page > 0 ? @deposits.total_pages : 1
  json.page @deposits.total_entries > 0 ? @deposits.current_page : 1
end

json.deposits @deposits do |deposit|
  json.cache! ['v6', deposit], skip_digest: true do
    json.(deposit, :id, :state, :message_type, :source_token, :callback, :timestamp)
  end
end
