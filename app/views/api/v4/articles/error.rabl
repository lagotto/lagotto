object false

node(:total) { 0 }
node(:total_pages) { 0 }
node(:page) { 0 }
node(:success) { nil }
node(:error) { @error }

node :data do
  partial "v4/articles/base", :object => @article
end
