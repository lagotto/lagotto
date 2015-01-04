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
      expect(subject.get_query_url(work)).to eq("http://en.wikipedia.org/w/api.php?action=query&list=search&format=json&srsearch=#{work.query_string}&srnamespace=0&srwhat=text&srinfo=totalhits&srprop=timestamp&srlimit=1")
    end
  end

  context "get_data" do
    it "should report that there are no events if the doi is missing" do
      work = FactoryGirl.build(:work, :doi => nil)
      expect(subject.get_data(work)).to eq({})
    end

    it "should report if there are no events and event_count returned by the Wikipedia API" do
      response = subject.get_data(work)
      expect(response).to eq("en"=>0)
    end

    it "should report if there are events and event_count returned by the Wikipedia API" do
      work = FactoryGirl.build(:work, :doi => "10.1371/journal.pcbi.1002445", canonical_url: "http://www.ploscompbiol.org/article/info%3Adoi%2F10.1371%2Fjournal.pcbi.1002445")
      response = subject.get_data(work)
      expect(response).to eq("en"=>2)
    end

    it "should catch timeout errors with the Wikipedia API" do
      work = FactoryGirl.build(:work, :doi => "10.1371/journal.pone.0000001")
      stub = stub_request(:get, /en.wikipedia.org/).to_return(:status => [408])
      response = subject.get_data(work, options = { :source_id => subject.id })
      expect(response).to eq("en"=>nil)
      expect(stub).to have_been_requested
      expect(Alert.count).to eq(1)
      alert = Alert.first
      expect(alert.class_name).to eq("Net::HTTPRequestTimeOut")
      expect(alert.message).to eq("the server responded with status 408 for http://en.wikipedia.org/w/api.php?action=query&list=search&format=json&srsearch=#{work.query_string}&srnamespace=0&srwhat=text&srinfo=totalhits&srprop=timestamp&srlimit=1")
      expect(alert.status).to eq(408)
      expect(alert.source_id).to eq(subject.id)
    end
  end

  context "get_data from Wikimedia Commons" do
    subject { FactoryGirl.create(:wikipedia, languages: "en commons") }

    it "should report if there are events and event_count returned by the Wikimedia Commons API" do
      work = FactoryGirl.build(:work, doi: "10.1371/journal.pone.0044271", canonical_url: "http://www.plosone.org/article/info:doi/10.1371/journal.pone.0044271")
      response = subject.get_data(work)
      expect(response).to eq("en"=>2, "commons"=>8)
    end

  end

  context "parse_data" do
    it "should report if the doi and canonical_url are missing" do
      work = FactoryGirl.build(:work, doi: nil, canonical_url: nil)
      result = {}
      expect(subject.parse_data(result, work)).to eq(events: {}, :events_by_day=>[], :events_by_month=>[], events_url: nil, event_count: 0, event_metrics: { pdf: nil, html: nil, shares: nil, groups: nil, comments: nil, likes: nil, citations: 0, total: 0 })
    end

    it "should report if there are no events and event_count returned by the Wikipedia API" do
      result = { "en"=>0 }
      expect(subject.parse_data(result, work)).to eq(events: {"en"=>0, "total"=>0}, :events_by_day=>[], :events_by_month=>[], events_url: "http://en.wikipedia.org/w/index.php?search=#{work.query_string}", event_count: 0, event_metrics: { pdf: nil, html: nil, shares: nil, groups: nil, comments: nil, likes: nil, citations: 0, total: 0 })
    end

    it "should report if there are events and event_count returned by the Wikipedia API" do
      work = FactoryGirl.build(:work, :doi => "10.1371/journal.pcbi.1002445")
      result = { "en"=>12 }
      response = subject.parse_data(result, work)
      expect(response[:events].length).to eq(1 + 1)
      expect(response[:event_count]).to eq(12)
    end

    it "should report if there are events and event_count returned by the Wikimedia Commons API" do
      work = FactoryGirl.build(:work, :doi => "10.1371/journal.pone.0044271")
      result = { "en"=>12, "commons"=>8 }
      response = subject.parse_data(result, work)
      expect(response[:events].length).to eq(1 + 1 + 1)
      expect(response[:event_count]).to eq(12 + 8)
    end

    it "should catch errors with the Wikipedia API" do
      work = FactoryGirl.create(:work, :doi => "10.2307/683422")
      result = { "en"=>nil }
      response = subject.parse_data(result, work)
      expect(response).to eq(:events=>{"en"=>nil, "total"=>0}, :events_by_day=>[], :events_by_month=>[], :events_url=>"http://en.wikipedia.org/w/index.php?search=#{work.query_string}", :event_count=>0, :event_metrics=>{:pdf=>nil, :html=>nil, :shares=>nil, :groups=>nil, :comments=>nil, :likes=>nil, :citations=>0, :total=>0})
    end
  end
end
