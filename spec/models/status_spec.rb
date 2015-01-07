require 'rails_helper'

describe Status, type: :model, vcr: true do
  subject { Status.new }

  before(:each) do
    date = Date.today - 1.day
    FactoryGirl.create_list(:work_with_events, 5, year: date.year, month: date.month, day: date.day)
    FactoryGirl.create_list(:alert, 2)
    FactoryGirl.create_list(:api_request, 4)
    FactoryGirl.create_list(:api_response, 6)
    StatusCacheJob.perform_later
  end

  it "works_count" do
    expect(subject.works_count).to eq(5)
  end

  it "works_last_day_count" do
    expect(subject.works_last_day_count).to eq(5)
  end

  it "events_count" do
    expect(subject.events_count).to eq(250)
  end

  it "alerts_count" do
    expect(subject.alerts_count).to eq(2)
  end

  it "responses_count" do
    expect(subject.responses_count).to eq(6)
  end

  it "requests_count" do
    expect(subject.requests_count).to eq(4)
  end

  it "current_version" do
    expect(subject.current_version).to eq("3.11")
  end
end
