require 'rails_helper'

describe Status do
  subject { Status.new }

  it "has state" do
    expect(subject.state).to eq("waiting")
  end

  it "has jobs" do
    expect(subject.jobs[:processed]).to be > 0
  end

  it "has deposit count" do
    FactoryGirl.create(:deposit)
    expect(subject.deposit_count).to eq(1)
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
