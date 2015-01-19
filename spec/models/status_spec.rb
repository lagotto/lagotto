require 'rails_helper'

describe Status, type: :model, vcr: true do
  subject { FactoryGirl.create(:status) }

  it "works_count" do
    expect(subject.works_count).to eq(5)
  end

  it "works_new_count" do
    expect(subject.works_new_count).to eq(0)
  end

  it "events_count" do
    expect(subject.events_count).to eq(0)
  end

  it "alerts_count" do
    expect(subject.alerts_count).to eq(0)
  end

  it "responses_count" do
    expect(subject.responses_count).to eq(5)
  end

  it "requests_count" do
    expect(subject.requests_count).to eq(5)
  end

  it "current_version" do
    expect(subject.current_version).to eq("3.13")
  end
end
