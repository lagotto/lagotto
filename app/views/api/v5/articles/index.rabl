object false

node(:total) {|m| @articles.total_entries }
node(:total_pages) {|m| (@articles.total_entries.to_f / @articles.per_page).ceil }
node(:page){|m| @articles.current_page}

node :data do
  partial("api/v5/articles/base", :object => @articles)
end