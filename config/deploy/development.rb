namespace :deploy do
  after :published, "db:seed"
end
