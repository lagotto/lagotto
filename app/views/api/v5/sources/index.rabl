object false
cache ['v5', @sources]

node(:total) { |m| @sources.size }
node(:error) { nil }

node :data do
  partial "v5/sources/base", :object => @sources
end
