require 'spec_helper'

describe "pmc:update" do
  include_context "rake"

  let(:pmc) { FactoryGirl.create(:pmc) }
  let(:month) { 1.month.ago.month }
  let(:year) { 1.month.ago.year }
  let(:journal) { "ajrccm" }
  let(:output) { "PMC Usage stats for month #{month} and year #{year} have been saved\nPMC Usage stats for month #{month} and year #{year} have been parsed\n" }

  before(:each) do
    pmc.put_alm_data(pmc.url)
  end

  after(:each) do
    pmc.delete_alm_data(pmc.url)
  end

  its(:prerequisites) { should include("environment") }

  it "should run the rake task" do
    stub = stub_request(:get, pmc.get_feed_url(month, year, journal)).to_return(:headers => { "Content-Type" => "application/xml" }, :body => File.read(fixture_path + 'pmc.xml'), :status => 200)
    capture_stdout { subject.invoke }.should eq(output)
  end
end