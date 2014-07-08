object false
cache ['v5', current_user, @source]

node(:error) { nil }

node :data do
  partial "v5/sources/base", :object => @source
end
