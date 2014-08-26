object false

node(:success) { @success }
node(:error) { nil }

child @article => :data do
  cache ['v4', current_user, @article]
  extends "v4/articles/base"
end
