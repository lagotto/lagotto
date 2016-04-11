require 'rails_helper'

describe Status, type: :model, vcr: true do
  subject { FactoryGirl.create(:status) }

  it "works_count" do
    FactoryGirl.create_list(:work, 5, :published_today)
    expect(subject.works_count).to eq(5)
  end

  it "works_new_count" do
    FactoryGirl.create_list(:work, 5, :published_today)
    expect(subject.works_new_count).to eq(5)
  end

  it "results_count" do
    FactoryGirl.create_list(:work, 5, :published_today)
    expect(subject.results_count).to eq(125)
  end

  it "notifications_count" do
    FactoryGirl.create_list(:notification, 5)
    expect(subject.notifications_count).to eq(5)
  end

  it "responses_count" do
    FactoryGirl.create_list(:api_response, 5)
    expect(subject.responses_count).to eq(5)
  end

  it "requests_count" do
    FactoryGirl.create_list(:api_request, 5, created_at: Time.zone.now - 1.hour)
    expect(subject.requests_count).to eq(5)
  end

  it "requests_average" do
    FactoryGirl.create_list(:api_request, 5, created_at: Time.zone.now - 1.hour)
    expect(subject.requests_average).to eq(800)
  end

  it "current_version" do
    expect(subject.current_version).to eq("3.13")
  end

  context "services" do
    it "redis" do
      expect(subject.redis).to eq("OK")
    end

    it "sidekiq" do
      expect(subject.sidekiq).to eq("failed")
    end

    it "services_ok?" do
      expect(subject.services_ok?).to be false
    end
  end
end
