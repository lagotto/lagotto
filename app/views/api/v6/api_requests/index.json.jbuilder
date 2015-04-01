json.meta do
  json.status "ok"
  json.message_type "api_request-list"
  json.total @api_requests.total_entries
  json.total_pages @api_requests.per_page > 0 ? @api_requests.total_pages : 1
  json.page @api_requests.total_entries > 0 ? @api_requests.current_page : 0
end

json.api_requests @api_requests do |api_request|
  json.(api_request, :api_key, :info, :source, :ids, :db_duration, :view_duration, :duration, :date)
end
