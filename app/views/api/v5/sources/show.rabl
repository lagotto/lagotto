object false
cache ['v5', current_user.cache_group, @source]

node(:error) { nil }

node :data do
  partial "v5/sources/base", :object => @source
end
