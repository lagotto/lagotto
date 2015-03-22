require 'rails_helper'

describe Wikipedia, type: :model, vcr: true do

  subject { FactoryGirl.create(:wikipedia) }

  let(:work) { FactoryGirl.build(:work, :doi => "10.1371/journal.pone.0044294", canonical_url: "http://www.plosone.org/article/info:doi/10.1371/journal.pone.0044294") }

  context "query_url" do
    it "should return nil if the doi and canonical_url are missing" do
      work = FactoryGirl.build(:work, :doi => nil, canonical_url: nil)
      expect(subject.get_query_url(work)).to be_nil
    end

    it "should return a query without doi if the doi is missing" do
      work = FactoryGirl.build(:work, :doi => nil)
      expect(subject.get_query_url(work)).to eq("http://en.wikipedia.org/w/api.php?action=query&list=search&format=json&srsearch=#{subject.get_query_string(work)}&srnamespace=0&srwhat=text&srinfo=totalhits&srprop=timestamp&srlimit=50&sroffset=0&continue=")
    end
  end

  context "get_data" do
    it "should report that there are no events if the doi is missing" do
      work = FactoryGirl.build(:work, :doi => nil)
      expect(subject.get_data(work)).to eq({})
    end

    it "should report if there are no events and event_count returned by the Wikipedia API" do
      response = subject.get_data(work)
      expect(response).to eq("en"=>[])
    end

    it "should report if there are events and event_count returned by the Wikipedia API" do
      work = FactoryGirl.build(:work, :doi => "10.1371/journal.pone.0008776", canonical_url: "http://journals.plos.org/plosone/article?id=10.1371/journal.pone.0008776")
      response = subject.get_data(work)
      expect(response["en"].length).to eq(637)
      expect(response["en"].first).to eq("title"=>"Lobatus costatus", "url"=>"http://en.wikipedia.org/wiki/Lobatus_costatus", "timestamp"=>"2013-03-21T09:51:18Z")
    end

    it "should catch timeout errors with the Wikipedia API" do
      work = FactoryGirl.build(:work, :doi => "10.1371/journal.pone.0000001")
      stub = stub_request(:get, /en.wikipedia.org/).to_return(:status => [408])
      response = subject.get_data(work, options = { :source_id => subject.id })
      expect(response).to eq("en"=>[])
      expect(stub).to have_been_requested
      expect(Alert.count).to eq(1)
      alert = Alert.first
      expect(alert.class_name).to eq("Net::HTTPRequestTimeOut")
      expect(alert.message).to eq("the server responded with status 408 for http://en.wikipedia.org/w/api.php?action=query&list=search&format=json&srsearch=#{subject.get_query_string(work)}&srnamespace=0&srwhat=text&srinfo=totalhits&srprop=timestamp&srlimit=50&sroffset=0&continue=")
      expect(alert.status).to eq(408)
      expect(alert.source_id).to eq(subject.id)
    end
  end

  context "get_data from Wikimedia Commons" do
    subject { FactoryGirl.create(:wikipedia, languages: "en commons") }

    it "should report if there are events and event_count returned by the Wikimedia Commons API" do
      work = FactoryGirl.build(:work, doi: "10.1371/journal.pone.0044271", canonical_url: "http://www.plosone.org/article/info:doi/10.1371/journal.pone.0044271")
      response = subject.get_data(work)
      expect(response["en"].length).to eq(2)
      expect(response["commons"].length).to eq(8)
    end

  end

  context "parse_data" do
    let(:null_response) { { :events=>[], :events_by_day=>[], :events_by_month=>[], :events_url=>nil, :event_count=>0, :event_metrics=>{:pdf=>nil, :html=>nil, :shares=>nil, :groups=>nil, :comments=>nil, :likes=>nil, :citations=>0, :total=>0 } } }

    it "should report if the doi and canonical_url are missing" do
      work = FactoryGirl.build(:work, doi: nil, canonical_url: nil)
      result = {}
      expect(subject.parse_data(result, work)).to eq(null_response)
    end

    it "should report if there are no events and event_count returned by the Wikipedia API" do
      result = { "en"=>[] }
      expect(subject.parse_data(result, work)).to eq(null_response)
    end

    it "should report if there are events and event_count returned by the Wikipedia API" do
      work = FactoryGirl.build(:work, :doi => "10.1371/journal.pone.0008776", canonical_url: "http://journals.plos.org/plosone/article?id=10.1371/journal.pone.0008776", published_on: "2007-07-01")
      body = File.read(fixture_path + 'wikipedia.json')
      result = JSON.parse(body)
      response = subject.parse_data(result, work)
      expect(response[:events].length).to eq(637)
      expect(response[:event_count]).to eq(637)
      expect(response[:event_metrics][:citations]).to eq(637)
      expect(response[:events_url]).to eq("http://en.wikipedia.org/w/index.php?search=#{subject.get_query_string(work)}")

      expect(response[:events_by_day].length).to eq(0)
      expect(response[:events_by_month].length).to eq(29)
      expect(response[:events_by_month].first).to eq(year: 2012, month: 5, total: 5)

      event = response[:events].first
      expect(event[:event_csl]['author']).to be_nil
      expect(event[:event_csl]['title']).to eq("Lobatus costatus")
      expect(event[:event_csl]['container-title']).to eq("Wikipedia")
      expect(event[:event_csl]['issued']).to eq("date-parts"=>[[2013, 3, 21]])
      expect(event[:event_csl]['type']).to eq("entry-encyclopedia")

      expect(event[:event_url]).to eq("http://en.wikipedia.org/wiki/Lobatus_costatus")
      expect(event[:event_time]).to eq("2013-03-21T09:51:18Z")
    end

    it "should report if there are events and event_count returned by the Wikimedia Commons API" do
      work = FactoryGirl.build(:work, :doi => "10.1371/journal.pone.0044271", published_on: "2007-07-01")
      body = File.read(fixture_path + 'wikipedia_commons.json')
      result = JSON.parse(body)
      response = subject.parse_data(result, work)
      expect(response[:events].length).to eq(10)
      expect(response[:event_count]).to eq(10)
      expect(response[:event_metrics][:citations]).to eq(10)
      expect(response[:events_url]).to eq("http://en.wikipedia.org/w/index.php?search=#{subject.get_query_string(work)}")

      expect(response[:events_by_day].length).to eq(0)
      expect(response[:events_by_month].length).to eq(3)
      expect(response[:events_by_month].first).to eq(year: 2013, month: 8, total: 6)

      event = response[:events].first
      expect(event[:event_csl]['author']).to be_nil
      expect(event[:event_csl]['title']).to eq("Lesula")
      expect(event[:event_csl]['container-title']).to eq("Wikipedia")
      expect(event[:event_csl]['issued']).to eq("date-parts"=>[[2014, 5, 24]])
      expect(event[:event_csl]['type']).to eq("entry-encyclopedia")

      expect(event[:event_url]).to eq("http://en.wikipedia.org/wiki/Lesula")
      expect(event[:event_time]).to eq("2014-05-24T12:54:07Z")
    end

    it "should catch errors with the Wikipedia API" do
      work = FactoryGirl.create(:work, :doi => "10.2307/683422")
      result = { "en"=>[] }
      response = subject.parse_data(result, work)
      expect(response).to eq(null_response)
    end
  end
end
