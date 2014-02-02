object false

node(:total) { 0 }
node(:total_pages) { 0 }
node(:page) { 0 }
node(:error) { @error }
node(:data) { [] }
unless @article.blank?
  node(:article) { @article }
end