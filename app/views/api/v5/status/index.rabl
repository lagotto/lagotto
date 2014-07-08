object false
cache ["v5#{current_user.cache_group}", @status]

node(:error) { nil }

node :data do
  partial "v5/status/base", :object => @status
end
