object false
cache ['v5', @api_requests]

node(:total) { |m| @api_requests.total_entries }
node(:total_pages) { |m| (@api_requests.total_entries.to_f / @api_requests.per_page).ceil }
node(:page) { |m| @api_requests.total_entries > 0 ? @api_requests.current_page : 0 }
node(:error) { nil }

child @api_requests => :data do
  attributes :api_key, :info, :source, :ids, :db_duration, :view_duration, :date
end
