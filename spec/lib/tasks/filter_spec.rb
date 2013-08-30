require 'spec_helper'

describe "filter:all" do
  include_context "rake"

  its(:prerequisites) { should include("environment") }

  context "found no errors" do

    before do
      FactoryGirl.create_list(:api_response, 3)
    end

    let(:output) { "Found 0 decreasing event count error(s)\nFound 0 increasing event count error(s)\nFound 0 API too slow error(s)\nFound 0 article not updated error(s)\n" }

    it "should run the rake task" do
      capture_stdout { subject.invoke }.should include(output)
    end
  end

  context "resolve all API requests" do

    before do
      FactoryGirl.create_list(:api_response, 3)
    end

    let(:output) { "Resolved 3 API response(s)\n" }

    it "should run the rake task" do
      capture_stdout { subject.invoke }.should include(output)
    end
  end

  context "report decreasing event count errors" do

    before do
      FactoryGirl.create_list(:api_response, 3, previous_count: 12)
    end

    let(:output) { "Found 3 decreasing event count error(s)\n" }

    it "should run the rake task" do
      capture_stdout { subject.invoke }.should include(output)
    end
  end

  context "report increasing event count errors" do

    before do
      FactoryGirl.create_list(:api_response, 3, event_count: 1050)
    end

    let(:output) { "Found 3 increasing event count error(s)\n" }

    it "should run the rake task" do
      capture_stdout { subject.invoke }.should include(output)
    end
  end

  context "report slow API response errors" do

    before do
      FactoryGirl.create_list(:api_response, 3, duration: 16000)
    end

    let(:output) { "Found 3 API too slow error(s)\n" }

    it "should run the rake task" do
      capture_stdout { subject.invoke }.should include(output)
    end
  end

  context "report not updated errors" do

    before do
      FactoryGirl.create_list(:api_response, 3, update_interval: 42)
    end

    let(:output) { "Found 3 article not updated error(s)\n" }

    it "should run the rake task" do
      capture_stdout { subject.invoke }.should include(output)
    end
  end
end
