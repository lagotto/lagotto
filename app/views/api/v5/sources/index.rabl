object false

node(:total) { |m| @sources.size }
node(:error) { nil }

child @sources => :data do
  cache ['v5', current_user, @sources]
  extends "v5/sources/base"
end
