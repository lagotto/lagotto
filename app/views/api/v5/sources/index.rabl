object false
cache ['v5', @sources]

node(:total) { |m| @sources.size }
node(:error) { nil }

child @sources => :data do
  attributes :name, :display_name, :state, :group, :description, :jobs, :responses, :error_count, :article_count, :event_count, :status, :by_day, :by_month, :update_date
end
