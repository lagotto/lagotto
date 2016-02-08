require 'foodcritic'
require 'rubocop/rake_task'
require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new do |task|
  task.rspec_opts = '--color -f d'
end
RuboCop::RakeTask.new(:rubocop)
FoodCritic::Rake::LintTask.new(:foodcritic)

task default: [:foodcritic, :rubocop, :spec]
