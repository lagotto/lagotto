require 'rails_helper'

describe Github, type: :model, vcr: true do
  subject { FactoryGirl.create(:github) }

  let(:work) { FactoryGirl.create(:work, :canonical_url => "https://github.com/ropensci/alm") }

  context "get_data" do
    it "should report that there are no events if the canonical_url is missing" do
      work = FactoryGirl.build(:work, :canonical_url => nil)
      expect(subject.get_data(work)).to eq({})
    end

    it "should report that there are no events if the canonical_url is not a Github URL" do
      work = FactoryGirl.build(:work, :canonical_url => "https://code.google.com/p/gwtupload/")
      expect(subject.get_data(work)).to eq({})
    end

    it "should report if there are no events and event_count returned by the Github API" do
      body = File.read(fixture_path + 'github_nil.json')
      stub = stub_request(:get, subject.get_query_url(work)).to_return(:body => body)
      response = subject.get_data(work)
      expect(response).to eq(JSON.parse(body))
      expect(stub).to have_been_requested
    end

    it "should report if there are events and event_count returned by the Github API" do
      body = File.read(fixture_path + 'github.json')
      stub = stub_request(:get, subject.get_query_url(work)).to_return(:body => body)
      response = subject.get_data(work)
      expect(response).to eq(JSON.parse(body))
      expect(stub).to have_been_requested
    end

    it "should catch timeout errors with the github API" do
      stub = stub_request(:get, subject.get_query_url(work)).to_return(:status => [408])
      response = subject.get_data(work, options = { :source_id => subject.id })
      expect(response).to eq(error: "the server responded with status 408 for https://api.github.com/repos/ropensci/alm", :status=>408)
      expect(stub).to have_been_requested
      expect(Alert.count).to eq(1)
      alert = Alert.first
      expect(alert.class_name).to eq("Net::HTTPRequestTimeOut")
      expect(alert.status).to eq(408)
      expect(alert.source_id).to eq(subject.id)
    end
  end

  context "parse_data" do
    let(:null_response) { { :events=>{}, :events_by_day=>[], :events_by_month=>[], :events_url=>nil, :event_count=>0, :event_metrics=>{:pdf=>nil, :html=>nil, :shares=>0, :groups=>nil, :comments=>nil, :likes=>0, :citations=>nil, :total=>0} } }

    it "should report if the canonical_url is missing" do
      work = FactoryGirl.build(:work, :canonical_url => nil)
      result = {}
      expect(subject.parse_data(result, work)).to eq(null_response)
    end

    it "should report that there are no events if the canonical_url is not a Github URL" do
      work = FactoryGirl.build(:work, :canonical_url => "https://code.google.com/p/gwtupload/")
      result = {}
      expect(subject.parse_data(result, work)).to eq(null_response)
    end

    it "should report if there are no events and event_count returned by the Github API" do
      body = File.read(fixture_path + 'github_nil.json')
      result = JSON.parse(body)
      events = { "stargazers_count"=>0, "stargazers_url"=>"https://api.github.com/repos/articlemetrics/pyalm/stargazers", "forks_count"=>0, "forks_url"=>"https://api.github.com/repos/articlemetrics/pyalm/forks" }
      response = subject.parse_data(result, work)
      expect(response).to eq(:events=>events, :events_by_day=>[], :events_by_month=>[], :events_url=>nil, :event_count=>0, :event_metrics=>{:pdf=>nil, :html=>nil, :shares=>0, :groups=>nil, :comments=>nil, :likes=>0, :citations=>nil, :total=>0})
    end

    it "should report if there are events and event_count returned by the Github API" do
      body = File.read(fixture_path + 'github.json')
      result = JSON.parse(body)
      response = subject.parse_data(result, work)
      expect(response[:event_count]).to eq(7)
      expect(response[:events]["stargazers_count"]).to eq(5)
      expect(response[:event_metrics]).to eq(pdf: nil, html: nil, shares: 2, groups: nil, comments: nil, likes: 5, citations: nil, total: 7)
    end

    it "should catch timeout errors with the github API" do
      work = FactoryGirl.create(:work, :doi => "10.1371/journal.pone.0000001")
      result = { error: "the server responded with status 408 for https://api.github.com/repos/ropensci/alm", status: 408 }
      response = subject.parse_data(result, work)
      expect(response).to eq(result)
    end
  end
end
