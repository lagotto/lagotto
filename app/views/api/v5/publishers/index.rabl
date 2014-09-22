object false
cache ['v5', @publishers]

node(:total) { |m| @publishers.total_entries }
node(:total_pages) { |m| (@publishers.total_entries.to_f / @publishers.per_page).ceil }
node(:page) { |m| @publishers.total_entries > 0 ? @publishers.current_page : 0 }
node(:error) { nil }

child @publishers => :data do
  attributes :name, :other_names, :crossref_id, :prefixes, :update_date
end
