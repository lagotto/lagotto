require 'rails_helper'

describe Status do
  subject { Status.new }

  it "has state" do
    expect(subject.state).to eq("waiting")
  end

  it "has jobs" do
    expect(subject.jobs[:processed]).to be_present
  end

  it "has event count" do
    FactoryGirl.create(:event)
    expect(subject.event_count).to eq(1)
  end

  it "has source count" do
    FactoryGirl.create(:source)
    expect(subject.source_count).to eq(1)
  end

  it "has work count" do
    FactoryGirl.create(:work)
    expect(subject.work_count).to eq(1)
  end
end
