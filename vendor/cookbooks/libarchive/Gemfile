source 'https://rubygems.org'

group :lint do
  gem 'foodcritic'
  gem 'rubocop'
end

group :kitchen_common do
  gem 'test-kitchen', '~> 1.4'
end

group :kitchen_vagrant do
  gem 'kitchen-vagrant', '~> 0.17'
end

group :kitchen_cloud do
  gem 'kitchen-openstack', '~> 1.8'
end

group :unit do
  gem 'chefspec'
end

group :integration do
  gem 'serverspec'
end

group :unit, :integration do
  gem 'berkshelf'
end

group :development do
  gem 'guard-kitchen'
  gem 'guard-foodcritic'
  gem 'guard-rspec'
  gem 'guard-rubocop'
  gem 'pry-byebug'
  gem 'rake'
end
