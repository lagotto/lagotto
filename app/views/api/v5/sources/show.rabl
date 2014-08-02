object false
cache ['v5', @source]

node(:error) { nil }

child @source => :data do
  attributes :name, :display_name, :state, :group, :description, :jobs, :responses, :error_count, :article_count, :event_count, :status, :by_day, :by_month, :update_date
end
