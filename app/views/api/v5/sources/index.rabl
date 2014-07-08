object false
cache ['v5', current_user, @sources]

node(:total) { |m| @sources.size }
node(:error) { nil }

node :data do
  partial "v5/sources/base", :object => @sources
end
