require 'rails_helper'

describe Wikipedia, type: :model, vcr: true do
  before(:each) { allow(Time.zone).to receive(:now).and_return(Time.mktime(2015, 4, 8)) }

  subject { FactoryGirl.create(:wikipedia) }

  let(:work) { FactoryGirl.create(:work, :doi => "10.1371/journal.pone.0044294", canonical_url: "http://www.plosone.org/article/info:doi/10.1371/journal.pone.0044294") }

  context "query_url" do
    it "should return empty hash if the doi and canonical_url are missing" do
      work = FactoryGirl.build(:work, :doi => nil, canonical_url: nil)
      expect(subject.get_query_url(work)).to eq({})
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
      expect(response["en"].length).to eq(627)
      expect(response["en"].first).to eq("title"=>"Bostrycapulus aculeatus", "url"=>"http://en.wikipedia.org/wiki/Bostrycapulus_aculeatus", "timestamp"=>"2015-03-21T07:47:45Z")
    end

    it "should catch timeout errors with the Wikipedia API" do
      work = FactoryGirl.build(:work, :doi => "10.1371/journal.pone.0000001")
      stub = stub_request(:get, /en.wikipedia.org/).to_return(:status => [408])
      response = subject.get_data(work, options = { :agent_id => subject.id })
      expect(response).to eq("en"=>[])
      expect(stub).to have_been_requested
      expect(Notification.count).to eq(1)
      notification = Notification.first
      expect(notification.class_name).to eq("Net::HTTPRequestTimeOut")
      expect(notification.message).to eq("the server responded with status 408 for http://en.wikipedia.org/w/api.php?action=query&list=search&format=json&srsearch=#{subject.get_query_string(work)}&srnamespace=0&srwhat=text&srinfo=totalhits&srprop=timestamp&srlimit=50&sroffset=0&continue=")
      expect(notification.status).to eq(408)
      expect(notification.agent_id).to eq(subject.id)
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
    it "should report if the doi and canonical_url are missing" do
      work = FactoryGirl.build(:work, doi: nil, canonical_url: nil)
      result = {}
      expect(subject.parse_data(result, work)).to eq(works: [], events: [{ source_id: "wikipedia", work_id: work.pid, total: 0, events_url: nil, extra: [], days: [], months: [] }])
    end

    it "should report if there are no events and event_count returned by the Wikipedia API" do
      result = { "en"=>[] }
      expect(subject.parse_data(result, work)).to eq(works: [], events: [{ source_id: "wikipedia", work_id: work.pid, total: 0, events_url: nil, extra: [], days: [], months: [] }])
    end

    it "should report if there are events and event_count returned by the Wikipedia API" do
      work = FactoryGirl.create(:work, :doi => "10.1371/journal.pone.0008776", canonical_url: "http://journals.plos.org/plosone/article?id=10.1371/journal.pone.0008776", published_on: "2007-07-01")
      body = File.read(fixture_path + 'wikipedia.json')
      result = JSON.parse(body)
      response = subject.parse_data(result, work)

      event = response[:events].first
      expect(event[:source_id]).to eq("wikipedia")
      expect(event[:work_id]).to eq(work.pid)
      expect(event[:total]).to eq(637)
      expect(event[:events_url]).to eq("http://en.wikipedia.org/w/index.php?search=#{subject.get_query_string(work)}")
      expect(event[:days].length).to eq(88)
      expect(event[:days].first).to eq(year: 2012, month: 5, day: 6, total: 1)
      expect(event[:months].length).to eq(29)
      expect(event[:months].first).to eq(year: 2012, month: 5, total: 5)

      expect(response[:works].length).to eq(637)
      related_work = response[:works].first
      expect(related_work['author']).to be_nil
      expect(related_work['title']).to eq("Lobatus costatus")
      expect(related_work['container-title']).to eq("Wikipedia")
      expect(related_work['issued']).to eq("date-parts"=>[[2013, 3, 21]])
      expect(related_work['timestamp']).to eq("2013-03-21T09:51:18Z")
      expect(related_work['URL']).to eq("http://en.wikipedia.org/wiki/Lobatus_costatus")
      expect(related_work['type']).to eq("entry-encyclopedia")
      expect(related_work['related_works']).to eq([{"pid"=>work.pid, "source_id"=>"wikipedia", "relation_type_id"=>"references"}])

      extra = event[:extra].first
      expect(extra[:event_url]).to eq("http://en.wikipedia.org/wiki/Lobatus_costatus")
      expect(extra[:event_time]).to eq("2013-03-21T09:51:18Z")
      expect(extra[:event_csl]['author']).to be_nil
      expect(extra[:event_csl]['title']).to eq("Lobatus costatus")
      expect(extra[:event_csl]['container-title']).to eq("Wikipedia")
      expect(extra[:event_csl]['issued']).to eq("date-parts"=>[[2013, 3, 21]])
      expect(extra[:event_csl]['type']).to eq("entry-encyclopedia")
    end

    it "should report if there are events and event_count returned by the Wikimedia Commons API" do
      work = FactoryGirl.create(:work, :doi => "10.1371/journal.pone.0044271", published_on: "2007-07-01")
      body = File.read(fixture_path + 'wikipedia_commons.json')
      result = JSON.parse(body)
      response = subject.parse_data(result, work)

      event = response[:events].first
      expect(event[:source_id]).to eq("wikipedia")
      expect(event[:work_id]).to eq(work.pid)
      expect(event[:total]).to eq(10)
      expect(event[:events_url]).to eq("http://en.wikipedia.org/w/index.php?search=#{subject.get_query_string(work)}")
      expect(event[:days].length).to eq(1)
      expect(event[:days].first).to eq(year: 2013, month: 8, day: 29, total: 6)
      expect(event[:months].length).to eq(3)
      expect(event[:months].first).to eq(year: 2013, month: 8, total: 6)

      expect(response[:works].length).to eq(10)
      related_work = response[:works].first
      expect(related_work['author']).to be_nil
      expect(related_work['title']).to eq("Lesula")
      expect(related_work['container-title']).to eq("Wikipedia")
      expect(related_work['issued']).to eq("date-parts"=>[[2014, 5, 24]])
      expect(related_work['timestamp']).to eq("2014-05-24T12:54:07Z")
      expect(related_work['URL']).to eq("http://en.wikipedia.org/wiki/Lesula")
      expect(related_work['type']).to eq("entry-encyclopedia")
      expect(related_work['related_works']).to eq([{"pid"=> work.pid, "source_id"=>"wikipedia", "relation_type_id"=>"references"}])

      extra = event[:extra].first
      expect(extra[:event_url]).to eq("http://en.wikipedia.org/wiki/Lesula")
      expect(extra[:event_time]).to eq("2014-05-24T12:54:07Z")
      expect(extra[:event_csl]['author']).to be_nil
      expect(extra[:event_csl]['title']).to eq("Lesula")
      expect(extra[:event_csl]['container-title']).to eq("Wikipedia")
      expect(extra[:event_csl]['issued']).to eq("date-parts"=>[[2014, 5, 24]])
      expect(extra[:event_csl]['type']).to eq("entry-encyclopedia")
    end

    it "should catch errors with the Wikipedia API" do
      work = FactoryGirl.create(:work, :doi => "10.2307/683422")
      result = { "en"=>[] }
      response = subject.parse_data(result, work)
      expect(response).to eq(works: [], events: [{ source_id: "wikipedia", work_id: work.pid, total: 0, events_url: nil, extra: [], days: [], months: [] }])
    end
  end
end
