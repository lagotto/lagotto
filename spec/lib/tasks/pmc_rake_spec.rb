require 'rails_helper'

describe "pmc:update" do
  include_context "rake"

  before(:each) do
    pmc.put_lagotto_data(pmc.url)
  end

  after(:each) do
    pmc.delete_lagotto_data(pmc.url)
  end

  let(:pmc) { FactoryGirl.create(:pmc) }
  let(:date) { Time.zone.now - 1.month }
  let(:month) { date.month.to_s }
  let(:year) { date.year.to_s }
  let(:output) { "Import of PMC usage stats queued for publisher Public Library of Science (PLoS), starting month #{month} and year #{year}\n" }

  it "prerequisites should include environment" do
    expect(subject.prerequisites).to include("environment")
  end

  it "should run the rake task" do
    config = pmc.publisher_configs.first
    publisher_id = config[0]
    journal = config[1].journals.split(" ").first
    stub = stub_request(:post, pmc.feed_url).to_return(:headers => { "Content-Type" => "application/xml" }, :body => File.read(fixture_path + 'pmc.xml'), :status => 200)
    expect(capture_stdout { subject.invoke }).to eq(output)
  end
end
