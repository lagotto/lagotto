object false
cache @sources

node(:total) { |m| @sources.size }
node(:error) { nil }

node :data do
  partial "v5/sources/show", :object => @sources
end