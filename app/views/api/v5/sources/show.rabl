object false
cache ['v5', current_user.is_admin_or_staff?, @source]

node(:error) { nil }

node :data do
  partial "v5/sources/base", :object => @source
end
