require 'spec_helper'

describe "report:alm_stats" do
  include_context "rake"

  let(:output) { "Report \"alm_stats_#{Date.today.iso8601}.csv\" has been written.\n" }

  its(:prerequisites) { should include("environment") }

  it "should run the rake task" do
    capture_stdout { subject.invoke }.should eq(output)
  end
end

describe "report:mendeley_stats" do
  include_context "rake"

  let(:url) { "#{CONFIG[:couchdb_url]}_design/reports/_view/mendeley" }
  let(:output) { "Report \"mendeley_#{Date.today.iso8601}.csv\" has been written.\n" }

  its(:prerequisites) { should include("environment") }

  it "should run the rake task" do
    stub = stub_request(:get, url).to_return(:body => File.read(fixture_path + 'mendeley_report.json'), :status => 200, :headers => { "Content-Type" => "application/json" })
    capture_stdout { subject.invoke }.should eq(output)
  end
end

describe "report:pmc_stats" do
  include_context "rake"

  let(:url) { "#{CONFIG[:couchdb_url]}_design/reports/_view/pmc" }
  let(:output) { "Report \"pmc_#{Date.today.iso8601}.csv\" has been written.\n" }

  its(:prerequisites) { should include("environment") }

  it "should run the rake task" do
    stub = stub_request(:get, url).to_return(:body => File.read(fixture_path + 'pmc_report.json'), :status => 200, :headers => { "Content-Type" => "application/json" })
    capture_stdout { subject.invoke }.should eq(output)
  end
end

describe "report:pmc_html_stats" do
  include_context "rake"

  let(:url) { "#{CONFIG[:couchdb_url]}_design/reports/_view/pmc_html_views" }
  let(:output) { "Report \"pmc_html_#{Date.today.iso8601}.csv\" has been written.\n" }

  its(:prerequisites) { should include("environment") }

  it "should run the rake task" do
    stub = stub_request(:get, url).to_return(:body => File.read(fixture_path + 'pmc_html_report.json'), :status => 200, :headers => { "Content-Type" => "application/json" })
    capture_stdout { subject.invoke }.should eq(output)
  end
end

describe "report:pmc_pdf_stats" do
  include_context "rake"

  let(:url) { "#{CONFIG[:couchdb_url]}_design/reports/_view/pmc_pdf_views" }
  let(:output) { "Report \"pmc_pdf_#{Date.today.iso8601}.csv\" has been written.\n" }

  its(:prerequisites) { should include("environment") }

  it "should run the rake task" do
    stub = stub_request(:get, url).to_return(:body => File.read(fixture_path + 'pmc_pdf_report.json'), :status => 200, :headers => { "Content-Type" => "application/json" })
    capture_stdout { subject.invoke }.should eq(output)
  end
end

describe "report:pmc_combined_stats" do
  include_context "rake"

  let(:url) { "#{CONFIG[:couchdb_url]}_design/reports/_view/pmc_combined_views" }
  let(:output) { "Report \"pmc_combined_#{Date.today.iso8601}.csv\" has been written.\n" }

  its(:prerequisites) { should include("environment") }

  it "should run the rake task" do
    stub = stub_request(:get, url).to_return(:body => File.read(fixture_path + 'pmc_combined_report.json'), :status => 200, :headers => { "Content-Type" => "application/json" })
    capture_stdout { subject.invoke }.should eq(output)
  end
end

describe "report:combined_stats" do
  include_context "rake"

  let(:output) { "Report \"alm_report_#{Date.today.iso8601}.csv\" has been written.\n" }

  its(:prerequisites) { should include("environment") }

  it "should run the rake task" do
    capture_stdout { subject.invoke }.should eq(output)
  end
end