object false

node(:total) { |m| @articles.total_entries }
node(:total_pages) { |m| (@articles.total_entries.to_f / @articles.per_page).ceil }
node(:page) { |m| @articles.total_entries > 0 ? @articles.current_page : 0 }
node(:error) { nil }

child @articles => :data do
  cache ['v5', current_user, @articles]
  extends "v5/articles/base"
end
