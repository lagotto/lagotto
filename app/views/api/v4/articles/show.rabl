object false

node(:success) { @success }
node(:error) { nil }

node :data do
  partial "v4/articles/base", :object => @article
end
