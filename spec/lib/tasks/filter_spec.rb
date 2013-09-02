require 'spec_helper'

describe "filter:all" do
  include_context "rake"

  its(:prerequisites) { should include("environment") }

  context "found no errors" do

    before do
      FactoryGirl.create(:api_response)
    end

    let(:output) { "Found 0 decreasing event count errors" }

    it "should run the rake task" do
      capture_stdout { subject.invoke }.should include(output)
    end
  end

  context "resolve all API requests" do

    before do
      FactoryGirl.create(:api_response)
    end

    let(:output) { "Resolved 1 API response" }

    it "should run the rake task" do
      capture_stdout { subject.invoke }.should include(output)
    end
  end

  context "report decreasing event count errors" do

    before do
      FactoryGirl.create(:api_response, previous_count: 12)
    end

    let(:output) { "Found 1 decreasing event count error" }

    it "should run the rake task" do
      capture_stdout { subject.invoke }.should include(output)
    end
  end

  context "report increasing event count errors" do

    before do
      FactoryGirl.create(:api_response, event_count: 3600)
    end

    let(:output) { "Found 1 increasing event count error" }

    it "should run the rake task" do
      capture_stdout { subject.invoke }.should include(output)
    end
  end

  context "report slow API response errors" do

    before do
      FactoryGirl.create(:api_response, duration: 16000)
    end

    let(:output) { "Found 1 API too slow error" }

    it "should run the rake task" do
      capture_stdout { subject.invoke }.should include(output)
    end
  end

  context "report article not updated errors" do

    before do
      FactoryGirl.create(:api_response, event_count: nil, update_interval: 42)
    end

    let(:output) { "Found 1 article not updated error" }

    it "should run the rake task" do
      capture_stdout { subject.invoke }.should include(output)
    end
  end

  context "report article not updated errors" do

    before do
      @citeulike = FactoryGirl.create(:citeulike)
      FactoryGirl.create(:mendeley)
      FactoryGirl.create(:api_response, source_id: @citeulike.id)
    end

    let(:output) { "Found 1 source not updated error" }

    it "should run the rake task" do
      capture_stdout { subject.invoke }.should include(output)
    end
  end
end

describe "filter:unresolve" do
  include_context "rake"

  its(:prerequisites) { should include("environment") }

    before do
      FactoryGirl.create(:api_response, unresolved: false)
    end

  let(:output) { "Unresolved 1 API response" }

  it "should run the rake task" do
    capture_stdout { subject.invoke }.should include(output)
  end
end
