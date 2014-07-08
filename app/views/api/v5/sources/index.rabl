object false
cache ['v5', current_user.is_admin_or_staff?, @sources]

node(:total) { |m| @sources.size }
node(:error) { nil }

node :data do
  partial "v5/sources/base", :object => @sources
end
