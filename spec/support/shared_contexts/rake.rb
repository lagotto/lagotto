# From http://robots.thoughtbot.com/post/11957424161/test-rake-tasks-like-a-boss
require "rake"

shared_context "rake" do
  let(:rake)      { Rake::Application.new }
  let(:task_name) { self.class.top_level_description.split("[").first }
  let(:regexp)    { Regexp.new('\[([\w,]+)\]') }
  let(:task_args) { regexp.match(self.class.top_level_description)[1].split(",") }
  let(:task_path) { "lib/tasks/#{task_name.split(':').first}" }
  subject         { rake[task_name] }

  def loaded_files_excluding_current_rake_file
    $LOADED_FEATURES.reject { |file| file == Rails.root.join("#{task_path}.rake").to_s }
  end

  before do
    Rake.application = rake
    # Rake.application.rake_require(task_path, [Rails.root.to_s], loaded_files_excluding_current_rake_file)
    Lagotto::Application.load_tasks
    Rake::Task.define_task(:environment)
  end
end
