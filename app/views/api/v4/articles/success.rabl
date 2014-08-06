object false

node(:success) { @success }
node(:error) { nil }

child @article => :data do
  extends "v4/articles/base"
end
