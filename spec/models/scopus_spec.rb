require 'rails_helper'

describe Scopus, type: :model, vcr: true do
  subject { FactoryGirl.create(:scopus) }

  let(:work) { FactoryGirl.build(:work, doi: "10.1371/journal.pmed.0030442", scp: nil) }

  context "get_data" do
    it "should report that there are no events if the DOI is missing" do
      work = FactoryGirl.build(:work, :doi => "")
      expect(subject.get_data(work)).to eq({})
    end

    it "should report if there are no events and event_count returned by the Scopus API" do
      work = FactoryGirl.build(:work, :doi => "10.1371/journal.pone.000001")
      body = File.read(fixture_path + 'scopus_nil.json')
      stub = stub_request(:get, subject.get_query_url(work)).with(:headers => { 'Accept'=>'application/json', 'User-Agent'=>"Lagotto #{Rails.application.config.version} - http://#{ENV['SERVERNAME']}", 'X-ELS-APIKEY' => subject.api_key, 'X-ELS-INSTTOKEN' => subject.insttoken }).to_return(:headers => { "Content-Type" => "application/json" }, :body => body, :status => 200)
      response = subject.get_data(work)
      expect(response).to eq(JSON.parse(body))
      expect(stub).to have_been_requested
    end

    it "should report if there are events and event_count returned by the Scopus API" do
      body = File.read(fixture_path + 'scopus.json')
      events = JSON.parse(body)["search-results"]["entry"][0]
      stub = stub_request(:get, subject.get_query_url(work)).with(:headers => { 'Accept'=>'application/json', 'User-Agent'=>"Lagotto #{Rails.application.config.version} - http://#{ENV['SERVERNAME']}", 'X-ELS-APIKEY' => subject.api_key, 'X-ELS-INSTTOKEN' => subject.insttoken }).to_return(:headers => { "Content-Type" => "application/json" }, :body => body, :status => 200)
      response = subject.get_data(work)
      expect(response).to eq(JSON.parse(body))
      expect(stub).to have_been_requested
    end

    it "should catch timeout errors with the Scopus API" do
      stub = stub_request(:get, subject.get_query_url(work)).to_return(:status => [408])
      response = subject.get_data(work, options = { :source_id => subject.id })
      expect(response).to eq(error: "the server responded with status 408 for https://api.elsevier.com/content/search/index:SCOPUS?query=DOI(#{work.doi_escaped})", :status=>408)
      expect(stub).to have_been_requested
      expect(Alert.count).to eq(1)
      alert = Alert.first
      expect(alert.class_name).to eq("Net::HTTPRequestTimeOut")
      expect(alert.status).to eq(408)
      expect(alert.source_id).to eq(subject.id)
    end

    context "parse_data" do
      it "should report if the doi is missing" do
        result = {}
        result.extend Hashie::Extensions::DeepFetch
        expect(subject.parse_data(result, work)).to eq(events: {}, :events_by_day=>[], :events_by_month=>[], events_url: nil, event_count: 0, event_metrics: { pdf: nil, html: nil, shares: nil, groups: nil, comments: nil, likes: nil, citations: 0, total: 0 })
      end

      it "should report if there are no events and event_count returned by the Scopus API" do
        body = File.read(fixture_path + 'scopus_nil.json')
        result = JSON.parse(body)
        result.extend Hashie::Extensions::DeepFetch
        work = FactoryGirl.build(:work, :doi => "10.1371/journal.pone.000001")
        response = subject.parse_data(result, work)
        expect(response).to eq(:events=>{"@force-array"=>"true", "error"=>"Result set was empty"}, :events_by_day=>[], :events_by_month=>[], :events_url=>nil, :event_count=>0, :event_metrics=>{:pdf=>nil, :html=>nil, :shares=>nil, :groups=>nil, :comments=>nil, :likes=>nil, :citations=>0, :total=>0})
      end

      it "should report if there are events and event_count returned by the Scopus API" do
        body = File.read(fixture_path + 'scopus.json')
        result = JSON.parse(body)
        result.extend Hashie::Extensions::DeepFetch
        events = JSON.parse(body)["search-results"]["entry"][0]
        response = subject.parse_data(result, work)
        expect(response).to eq(events: events, :events_by_day=>[], :events_by_month=>[], event_count: 1814, events_url: "http://www.scopus.com/inward/citedby.url?partnerID=HzOxMe3b&scp=33845338724", event_metrics: { pdf: nil, html: nil, shares: nil, groups: nil, comments: nil, likes: nil, citations: 1814, total: 1814 })
        expect(work.scp).to eq("33845338724")
      end

      it "should catch timeout errors with the Scopus API" do
        work = FactoryGirl.create(:work, :doi => "10.2307/683422")
        result = { error: "the server responded with status 408 for https://api.elsevier.com/content/search/index:SCOPUS?query=DOI(#{work.doi_escaped})", status: 408 }
        response = subject.parse_data(result, work)
        expect(response).to eq(result)
      end
    end
  end
end
