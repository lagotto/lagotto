object false
cache ['v5', @source]

node(:error) { nil }

node :data do
  partial "v5/sources/base", :object => @source
end
