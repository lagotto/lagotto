require 'rails_helper'

describe "pmc:update" do
  include_context "rake"

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
    stub = stub_request(:get, pmc.get_feed_url(publisher_id, month, year, journal)).to_return(:headers => { "Content-Type" => "application/xml" }, :body => File.read(fixture_path + 'pmc.xml'), :status => 200)
    expect(capture_stdout { subject.invoke }).to eq(output)
  end
end
