require 'rails_helper'

describe "db:works:import:crossref" do
  ENV['FROM_UPDATE_DATE'] = "2013-09-04"
  ENV['UNTIL_UPDATE_DATE'] = "2013-09-05"
  ENV['FROM_PUB_DATE'] = "2013-09-04"
  ENV['UNTIL_PUB_DATE'] = "2013-09-05"

  include_context "rake"

  let(:output) { "Started import of 993 works in the background...\n" }

  it "prerequisites should include environment" do
    expect(subject.prerequisites).to include("environment")
  end

  it "should run the rake task" do
    import = CrossrefImport.new
    stub_request(:get, import.query_url(offset = 0, rows = 0)).to_return(:body => File.read(fixture_path + 'crossref_import_no_rows_single.json'))
    stub_request(:get, import.query_url).to_return(:body => File.read(fixture_path + 'crossref_import.json'))
    stub_request(:get, "http://#{ENV['SERVERNAME']}/api/v5/status?api_key=#{ENV['API_KEY']}")
    expect(capture_stdout { subject.invoke }).to eq(output)
  end

  it "should run the rake task for a sample" do
    ENV['SAMPLE'] = "50"
    output = "Started import of 50 works in the background...\n"
    import = CrossrefImport.new(sample: 50)
    stub_request(:get, import.query_url).to_return(:body => File.read(fixture_path + 'crossref_import.json'))
    stub_request(:get, "http://#{ENV['SERVERNAME']}/api/v5/status?api_key=#{ENV['API_KEY']}")
    expect(capture_stdout { subject.invoke }).to eq(output)
    ENV['SAMPLE'] = nil
  end
end

describe "db:works:import:datacite" do
  ENV['FROM_UPDATE_DATE'] = "2013-09-04"
  ENV['UNTIL_UPDATE_DATE'] = "2013-09-05"
  ENV['FROM_PUB_DATE'] = "2013-09-04"
  ENV['UNTIL_PUB_DATE'] = "2013-09-05"

  include_context "rake"

  let(:output) { "Started import of 636 works in the background...\n" }

  it "prerequisites should include environment" do
    expect(subject.prerequisites).to include("environment")
  end

  it "should run the rake task" do
    import = DataciteImport.new
    stub_request(:get, import.query_url(offset = 0, rows = 0)).to_return(:body => File.read(fixture_path + 'datacite_import_no_rows_single.json'))
    stub_request(:get, import.query_url).to_return(:body => File.read(fixture_path + 'datacite_import.json'))
    stub_request(:get, "http://#{ENV['SERVERNAME']}/api/v5/status?api_key=#{ENV['API_KEY']}")
    expect(capture_stdout { subject.invoke }).to eq(output)
  end
end

describe "db:works:import:plos" do
  ENV['FROM_PUB_DATE'] = "2013-09-04"
  ENV['UNTIL_PUB_DATE'] = "2013-09-05"

  include_context "rake"

  let(:output) { "Started import of 29 works in the background...\n" }

  it "prerequisites should include environment" do
    expect(subject.prerequisites).to include("environment")
  end

  it "should run the rake task" do
    import = PlosImport.new
    stub_request(:get, import.query_url(offset = 0, rows = 0)).to_return(:body => File.read(fixture_path + 'plos_import_no_rows_single.json'))
    stub_request(:get, import.query_url).to_return(:body => File.read(fixture_path + 'plos_import.json'))
    stub_request(:get, "http://#{ENV['SERVERNAME']}/api/v5/status?api_key=#{ENV['API_KEY']}")
    expect(capture_stdout { subject.invoke }).to eq(output)
  end
end

describe "db:works:import:dataone" do
  ENV['FROM_PUB_DATE'] = "2013-09-04"
  ENV['UNTIL_PUB_DATE'] = "2013-09-05"

  include_context "rake"

  let(:output) { "Started import of 29 works in the background...\n" }

  it "prerequisites should include environment" do
    expect(subject.prerequisites).to include("environment")
  end

  it "should run the rake task" do
    import = PlosImport.new
    stub_request(:get, import.query_url(offset = 0, rows = 0)).to_return(:body => File.read(fixture_path + 'plos_import_no_rows_single.json'))
    stub_request(:get, import.query_url).to_return(:body => File.read(fixture_path + 'dataone_import.json'))
    stub_request(:get, "http://#{ENV['SERVERNAME']}/api/v5/status?api_key=#{ENV['API_KEY']}")
    expect(capture_stdout { subject.invoke }).to eq(output)
  end
end

describe "db:works:import:csl" do
  # we are not providing a file to import, so this should raise an error

  include_context "rake"

  it "prerequisites should include environment" do
    expect(subject.prerequisites).to include("environment")
  end

  it "should run the rake task" do
    expect{ subject.invoke }.to raise_error Errno::EISDIR
  end
end

describe "db:articles:load" do
  # we are not providing a file to import, so this should raise an error

  include_context "rake"

  it "prerequisites should include environment" do
    expect(subject.prerequisites).to include("environment")
  end

  it "should run the rake task" do
    expect{ subject.invoke }.to raise_error SystemExit
  end
end

describe "db:works:delete" do
  include_context "rake"

  before do
    FactoryGirl.create_list(:work, 5)
  end

  let(:output) { "Started deleting all works in the background...\n" }

  it "should run" do
    ENV['MEMBER'] = "all"
    expect(capture_stdout { subject.invoke }).to eq(output)
    ENV['MEMBER'] = nil
  end
end

describe "db:works:sanitize_title" do
  include_context "rake"

  before do
    FactoryGirl.create_list(:work, 5)
  end

  let(:output) { "5 work titles sanitized\n" }

  it "should run" do
    expect(capture_stdout { subject.invoke }).to eq(output)
  end
end

describe "db:alerts:delete" do
  include_context "rake"

  before do
    FactoryGirl.create_list(:alert, 5, :unresolved => false)
  end

  let(:output) { "Deleted 5 resolved alerts, 0 unresolved alerts remaining\n" }

  it "should run" do
    expect(capture_stdout { subject.invoke }).to eq(output)
  end
end

describe "db:api_requests:delete" do
  include_context "rake"

  before do
    FactoryGirl.create_list(:api_request, 5)
  end

  let(:output) { "Deleted 0 API requests, 5 API requests remaining\n" }

  it "should run" do
    expect(capture_stdout { subject.invoke }).to eq(output)
  end
end

describe "db:api_responses:delete" do
  include_context "rake"

  before do
    FactoryGirl.create_list(:api_response, 5, unresolved: false, created_at: Time.zone.now - 2.days)
  end

  let(:output) { "Deleted 5 API responses, 0 API responses remaining\n" }

  it "should run" do
    expect(capture_stdout { subject.invoke }).to eq(output)
  end
end

describe "db:sources:activate" do
  include_context "rake"

  before do
    FactoryGirl.create(:source, state_event: 'install')
  end

  let(:output) { "Source CiteULike has been activated and is now waiting.\n" }

  it "should run" do
    expect(capture_stdout { subject.invoke }).to eq(output)
  end
end

describe "db:sources:inactivate" do
  include_context "rake"

  before do
    FactoryGirl.create(:source)
  end

  let(:output) { "Source CiteULike has been inactivated.\n" }

  it "should run" do
    expect(capture_stdout { subject.invoke }).to eq(output)
  end
end

describe "db:sources:install" do
  include_context "rake"

  before do
    FactoryGirl.create(:source, state_event: nil)
  end

  let(:output) { "Source CiteULike has been installed.\n" }

  it "should run" do
    expect(capture_stdout { subject.invoke }).to eq(output)
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
    expect(capture_stdout { subject.invoke(*task_args) }).to eq(output)
  end
end
