object false

node(:total) { |m| @alerts.total_entries }
node(:total_pages) { |m| (@alerts.total_entries.to_f / @alerts.per_page).ceil }
node(:page) { |m| @alerts.total_entries > 0 ? @alerts.current_page : 0 }
node(:error) { nil }

child @alerts => :data do
  cache ['v4', @alerts]

  attributes :id, :level, :class_name, :message, :status, :hostname, :source, :article, :unresolved, :create_date, :update_date
end
