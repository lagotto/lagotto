object false

node(:error) { nil }

child @source => :data do
  cache ['v5', @source]
  extends "v5/sources/base"
end
