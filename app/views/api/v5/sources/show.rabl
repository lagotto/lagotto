object false
cache @source

node(:error) { nil }

node :data do
  partial "v5/sources/base", :object => @source
end