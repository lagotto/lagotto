require 'spec_helper'

describe Status do
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
    subject.articles_count.should == 5
  end

  it "articles_last30_count" do
    subject.articles_last30_count.should == 5
  end

  it "events_count" do
    subject.events_count.should == 250
  end

  it "alerts_last_day_count" do
    subject.alerts_last_day_count.should ==2
  end

  it "delayed_jobs_active_count" do
    subject.delayed_jobs_active_count.should == 1
  end

  it "responses_count" do
    subject.responses_count.should == 6
  end

  it "requests_count" do
    subject.requests_count.should == 4
  end

  it "current_version" do
    subject.current_version.should == "3.6.3"
  end
end
