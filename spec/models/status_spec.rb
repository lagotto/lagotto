require 'rails_helper'

describe Status, :type => :model do
  subject { Status.new }

  before(:each) do
    date = Date.today - 1.day
    FactoryGirl.create_list(:article_with_events, 5, year: date.year, month: date.month, day: date.day)
    FactoryGirl.create_list(:alert, 2)
    FactoryGirl.create(:delayed_job)
    FactoryGirl.create_list(:api_request, 4)
    FactoryGirl.create_list(:api_response, 6)
    body = File.read(fixture_path + 'releases.json')
    stub_request(:get, "https://api.github.com/repos/articlemetrics/lagotto/releases").to_return(body: body)
    subject.update_cache
  end

  it "articles_count" do
    expect(subject.articles_count).to eq(5)
  end

  it "articles_last30_count" do
    expect(subject.articles_last30_count).to eq(5)
  end

  it "events_count" do
    expect(subject.events_count).to eq(250)
  end

  it "alerts_count" do
    expect(subject.alerts_count).to eq(2)
  end

  it "delayed_jobs_active_count" do
    expect(subject.delayed_jobs_active_count).to eq(1)
  end

  it "responses_count" do
    expect(subject.responses_count).to eq(6)
  end

  it "requests_count" do
    expect(subject.requests_count).to eq(4)
  end

  it "current_version" do
    expect(subject.current_version).to eq("3.6.3")
  end
end
