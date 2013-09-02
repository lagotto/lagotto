require 'spec_helper'

describe "filter:all" do
  include_context "rake"

  its(:prerequisites) { should include("environment") }

  context "found no errors" do

    before do
      FactoryGirl.create_list(:api_response, 3)
    end

    let(:output) { "Found 0 decreasing event count errors" }

    it "should run the rake task" do
      capture_stdout { subject.invoke }.should include(output)
    end
  end

  context "resolve all API requests" do

    before do
      FactoryGirl.create_list(:api_response, 3)
    end

    let(:output) { "Resolved 3 API responses" }

    it "should run the rake task" do
      capture_stdout { subject.invoke }.should include(output)
    end
  end

  context "report decreasing event count errors" do

    before do
      FactoryGirl.create_list(:api_response, 3, previous_count: 12)
    end

    let(:output) { "Found 3 decreasing event count errors" }

    it "should run the rake task" do
      capture_stdout { subject.invoke }.should include(output)
    end
  end

  context "report increasing event count errors" do

    before do
      FactoryGirl.create_list(:api_response, 3, event_count: 3600)
    end

    let(:output) { "Found 3 increasing event count errors" }

    it "should run the rake task" do
      capture_stdout { subject.invoke }.should include(output)
    end
  end

  context "report slow API response errors" do

    before do
      FactoryGirl.create_list(:api_response, 3, duration: 16000)
    end

    let(:output) { "Found 3 API too slow errors" }

    it "should run the rake task" do
      capture_stdout { subject.invoke }.should include(output)
    end
  end

  context "report article not updated errors" do

    before do
      FactoryGirl.create_list(:api_response, 3, event_count: nil, update_interval: 42)
    end

    let(:output) { "Found 3 article not updated errors" }

    it "should run the rake task" do
      capture_stdout { subject.invoke }.should include(output)
    end
  end

  context "report article not updated errors" do

    before do
      @citeulike = FactoryGirl.create(:citeulike)
      FactoryGirl.create(:mendeley)
      FactoryGirl.create_list(:api_response, 3, source_id: @citeulike.id)
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
      FactoryGirl.create_list(:api_response, 3, unresolved: false)
    end

  let(:output) { "Unresolved 3 API responses" }

  it "should run the rake task" do
    capture_stdout { subject.invoke }.should include(output)
  end
end
