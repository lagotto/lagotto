object false

node(:error) { nil }

child @source => :data do
  extends "v5/sources/base"
end
