require 'spec_helper'

describe "db:articles:seed" do
  include_context "rake"

  let(:output) { "Seeded 35 articles\n" }

  its(:prerequisites) { should include("environment") }

  it "should run the rake task" do
    capture_stdout { subject.invoke }.should eq(output)
  end
end

describe "db:articles:import" do
  include_context "rake"

  let(:output) { "Started import of 993 articles in the background...\n" }

  its(:prerequisites) { should include("environment") }

  it "should run the rake task" do
    import = Import.new
    stub_request(:get, import.query_url(offset = 0, rows = 0)).to_return(:body => File.read(fixture_path + 'import_no_rows_single.json'))
    stub_request(:get, import.query_url).to_return(:body => File.read(fixture_path + 'import.json'))
    stub_request(:get, "http://#{CONFIG[:public_server]}/api/v5/status?api_key=#{CONFIG[:api_key]}")
    capture_stdout { subject.invoke }.should eq(output)
  end

  it "should run the rake task for a sample" do
    ENV['SAMPLE'] = "50"
    output = "Started import of 50 articles in the background...\n"
    import = Import.new(sample: 50)
    stub_request(:get, import.query_url).to_return(:body => File.read(fixture_path + 'import.json'))
    stub_request(:get, "http://#{CONFIG[:public_server]}/api/v5/status?api_key=#{CONFIG[:api_key]}")
    capture_stdout { subject.invoke }.should eq(output)
  end
end

describe "db:articles:delete_all" do
  include_context "rake"

  before do
    FactoryGirl.create_list(:article, 5)
  end

  let(:output) { "Deleted 5 articles, 0 articles remaining\n" }

  it "should run" do
    capture_stdout { subject.invoke }.should eq(output)
  end
end

describe "db:articles:sanitize_title" do
  include_context "rake"

  before do
    FactoryGirl.create_list(:article, 5)
  end

  let(:output) { "5 article titles sanitized\n" }

  it "should run" do
    capture_stdout { subject.invoke }.should eq(output)
  end
end

describe "db:alerts:delete" do
  include_context "rake"

  before do
    FactoryGirl.create_list(:alert, 5, :unresolved => false)
  end

  let(:output) { "Deleted 5 resolved alerts, 0 unresolved alerts remaining\n" }

  it "should run" do
    capture_stdout { subject.invoke }.should eq(output)
  end
end

describe "db:api_requests:delete" do
  include_context "rake"

  before do
    FactoryGirl.create_list(:api_request, 5)
  end

  let(:output) { "Deleted 0 API requests, 5 API requests remaining\n" }

  it "should run" do
    capture_stdout { subject.invoke }.should eq(output)
  end
end

describe "db:api_responses:delete" do
  include_context "rake"

  before do
    FactoryGirl.create_list(:api_response, 5, unresolved: false, created_at: Time.zone.now - 2.days)
  end

  let(:output) { "Deleted 5 API responses, 0 API responses remaining\n" }

  it "should run" do
    capture_stdout { subject.invoke }.should eq(output)
  end
end

describe "db:sources:activate" do
  include_context "rake"

  before do
    FactoryGirl.create(:source, state_event: 'install')
  end

  let(:output) { "Source CiteULike has been activated and is now waiting.\n" }

  it "should run" do
    capture_stdout { subject.invoke }.should eq(output)
  end
end

describe "db:sources:inactivate" do
  include_context "rake"

  before do
    FactoryGirl.create(:source)
  end

  let(:output) { "Source CiteULike has been inactivated.\n" }

  it "should run" do
    capture_stdout { subject.invoke }.should eq(output)
  end
end

describe "db:sources:install" do
  include_context "rake"

  before do
    FactoryGirl.create(:source, state_event: nil)
  end

  let(:output) { "Source CiteULike has been installed.\n" }

  it "should run" do
    capture_stdout { subject.invoke }.should eq(output)
  end
end

describe "db:sources:uninstall[citeulike,pmc]" do
  include_context "rake"

  before do
    FactoryGirl.create(:source)
    FactoryGirl.create(:pmc)
  end

  let(:output) { "Source CiteULike has been uninstalled.\nSource PubMed Central Usage Stats has been uninstalled.\n" }

  it "should run" do
    capture_stdout { subject.invoke(*task_args) }.should eq(output)
  end
end
