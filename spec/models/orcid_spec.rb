require 'rails_helper'

describe Orcid, type: :model, vcr: true do
  subject { FactoryGirl.create(:orcid) }

  let(:work) { FactoryGirl.build(:work, doi: "10.1371/journal.pone.0018011", published_on: "2009-09-01") }

  context "get_data" do
    it "should report that there are no events if the doi is missing" do
      work = FactoryGirl.build(:work, :doi => nil)
      expect(subject.get_data(work)).to eq({})
    end

    it "should report if there are no events and event_count returned by the ORCID API" do
      work = FactoryGirl.build(:work, :doi => "10.1371/journal.pone.0044294")
      response = subject.get_data(work)
      expect(response).to eq("message-version"=>"1.1", "orcid-search-results"=>{"orcid-search-result"=>[], "num-found"=>0})
    end

    it "should report if there are events and event_count returned by the ORCID API" do
      response = subject.get_data(work)
      expect(response["orcid-search-results"]["num-found"]).to eq(1)
      profile = response["orcid-search-results"]["orcid-search-result"].first
      expect(profile["orcid-profile"]["orcid-identifier"]["uri"]).to eq("http://orcid.org/0000-0002-0159-2197")
    end

    it "should catch timeout errors with the ORCID API" do
      work = FactoryGirl.build(:work, :doi => "10.1371/journal.pone.0000001")
      stub = stub_request(:get, subject.get_query_url(work)).to_return(:status => [408])
      response = subject.get_data(work, options = { :source_id => subject.id })
      expect(response).to eq(error: "the server responded with status 408 for http://pub.orcid.org/v1.1/search/orcid-bio/?q=digital-object-ids:\"#{work.doi_escaped}\"&rows=100", :status=>408)
      expect(stub).to have_been_requested
      expect(Alert.count).to eq(1)
      alert = Alert.first
      expect(alert.class_name).to eq("Net::HTTPRequestTimeOut")
      expect(alert.status).to eq(408)
      expect(alert.source_id).to eq(subject.id)
    end
  end

  context "parse_data" do
    let(:null_response) { { events: [], :events_by_day=>[], :events_by_month=>[], :events_url=>nil, event_count: 0, event_metrics: { pdf: nil, html: nil, shares: 0, groups: nil, comments: nil, likes: nil, citations: nil, total: 0 } } }

    it "should report if the doi is missing" do
      work = FactoryGirl.build(:work, :doi => nil)
      result = {}
      expect(subject.parse_data(result, work)).to eq(null_response)
    end

    it "should report if there are no events and event_count returned by the ORCID API" do
      body = File.read(fixture_path + 'orcid_nil.json')
      result = JSON.parse(body)
      response = subject.parse_data(result, work)
      expect(response).to eq(null_response)
    end

    it "should report if there are events and event_count returned by the ORCID API" do
      body = File.read(fixture_path + 'orcid.json')
      result = JSON.parse(body)
      response = subject.parse_data(result, work)
      expect(response[:event_count]).to eq(1)

      event = response[:events].first
      expect(event[:event_url]).to eq("http://orcid.org/0000-0002-0159-2197")
      expect(event[:event]["orcid-bio"]["personal-details"]).to eq("given-names"=>{"value"=>"Jonathan A."}, "family-name"=>{"value"=>"Eisen"})
    end
  end
end
