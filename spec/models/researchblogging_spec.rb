require 'rails_helper'

describe Researchblogging, :type => :model do
  subject { FactoryGirl.create(:researchblogging) }

  context "get_data" do
    let(:auth) { ActionController::HttpAuthentication::Basic.encode_credentials(subject.username, subject.password) }

    it "should report that there are no events if the doi is missing" do
      work = FactoryGirl.build(:work, :doi => "")
      expect(subject.get_data(work)).to eq({})
    end

    it "should report if there are no events and event_count returned by the ResearchBlogging API" do
      work = FactoryGirl.build(:work, :doi => "10.1371/journal.pmed.0020124")
      body = File.read(fixture_path + 'researchblogging_nil.xml')
      stub = stub_request(:get, "http://researchbloggingconnect.com/blogposts?article=doi:#{work.doi_escaped}&count=100").with(:headers => { :authorization => auth }).to_return(:body => body)
      response = subject.get_data(work)
      expect(response).to eq(Hash.from_xml(body))
      expect(stub).to have_been_requested
    end

    it "should report if there are events and event_count returned by the ResearchBlogging API" do
      work = FactoryGirl.build(:work, :doi => "10.1371/journal.pone.0035869")
      body = File.read(fixture_path + 'researchblogging.xml')
      stub = stub_request(:get, "http://researchbloggingconnect.com/blogposts?article=doi:#{work.doi_escaped}&count=100").with(:headers => { :authorization => auth }).to_return(:body => body)
      response = subject.get_data(work)
      expect(response).to eq(Hash.from_xml(body))
      expect(stub).to have_been_requested
    end

    it "should catch errors with the ResearchBlogging API" do
      work = FactoryGirl.build(:work, :doi => "10.1371/journal.pone.0000001")
      stub = stub_request(:get, "http://researchbloggingconnect.com/blogposts?article=doi:#{work.doi_escaped}&count=100").with(:headers => { :authorization => auth }).to_return(:status => [408])
      response = subject.get_data(work, options = { :source_id => subject.id })
      expect(response).to eq(error: "the server responded with status 408 for http://researchbloggingconnect.com/blogposts?count=100&article=doi:#{work.doi_escaped}", :status=>408)
      expect(stub).to have_been_requested
      expect(Alert.count).to eq(1)
      alert = Alert.first
      expect(alert.class_name).to eq("Net::HTTPRequestTimeOut")
      expect(alert.status).to eq(408)
      expect(alert.source_id).to eq(subject.id)
    end
  end

  context "parse_data" do
    let(:work) { FactoryGirl.build(:work, :doi => "10.1371/journal.pmed.0020124") }

    it "should report if the doi is missing" do
      work = FactoryGirl.build(:work, :doi => "")
      result = {}
      result.extend Hashie::Extensions::DeepFetch
      expect(subject.parse_data(result, work)).to eq(events: [], :events_by_day=>[], :events_by_month=>[], events_url: nil, event_count: 0, event_metrics: { pdf: nil, html: nil, shares: nil, groups: nil, comments: nil, likes: nil, citations: 0, total: 0 })
    end

    it "should report if there are no events and event_count returned by the ResearchBlogging API" do
      body = File.read(fixture_path + 'researchblogging_nil.xml')
      result = Hash.from_xml(body)
      result.extend Hashie::Extensions::DeepFetch
      response = subject.parse_data(result, work)
      expect(response).to eq(events: [], :events_by_day=>[], :events_by_month=>[], event_count: 0, event_metrics: { pdf: nil, html: nil, shares: nil, groups: nil, comments: nil, likes: nil, citations: 0, total: 0 }, events_url: subject.get_events_url(work))
    end

    it "should report if there are events and event_count returned by the ResearchBlogging API" do
      work = FactoryGirl.build(:work, :doi => "10.1371/journal.pone.0035869", published_on: "2009-07-01")
      body = File.read(fixture_path + 'researchblogging.xml')
      result = Hash.from_xml(body)
      result.extend Hashie::Extensions::DeepFetch
      response = subject.parse_data(result, work)
      expect(response[:event_count]).to eq(8)
      expect(response[:events].length).to eq(8)
      expect(response[:events_url]).to eq(subject.get_events_url(work))

      expect(response[:events_by_day].length).to eq(1)
      expect(response[:events_by_day].first).to eq(year: 2009, month: 7, day: 6, total: 1)
      expect(response[:events_by_month].length).to eq(7)
      expect(response[:events_by_month].first).to eq(year: 2009, month: 7, total: 1)

      event = response[:events].first

      expect(event[:event_csl]['author']).to eq([{"family"=>"Spoetnik", "given"=>"Laika"}])
      expect(event[:event_csl]['title']).to eq("Why Publishing in the NEJM is not the Best Guarantee that Something is True: a Response to Katan")
      expect(event[:event_csl]['container-title']).to eq("Laika's Medliblog")
      expect(event[:event_csl]['issued']).to eq("date-parts"=>[[2012, 10, 27]])
      expect(event[:event_csl]['type']).to eq("post")

      expect(event[:event_time]).to eq("2012-10-27T11:32:09Z")
      expect(event[:event_url]).to eq(event[:event]["post_URL"])
    end

    it "should report if there is one event returned by the ResearchBlogging API" do
      work = FactoryGirl.build(:work, :doi => "10.1371/journal.pone.0035869", published_on: "2012-10-01")
      body = File.read(fixture_path + 'researchblogging_one.xml')
      result = Hash.from_xml(body)
      result.extend Hashie::Extensions::DeepFetch
      response = subject.parse_data(result, work)
      expect(response[:event_count]).to eq(1)
      expect(response[:events].length).to eq(1)
      expect(response[:events_url]).to eq(subject.get_events_url(work))

      expect(response[:events_by_day].length).to eq(1)
      expect(response[:events_by_day].first).to eq(year: 2012, month: 10, day: 27, total: 1)
      expect(response[:events_by_month].length).to eq(1)
      expect(response[:events_by_month].first).to eq(year: 2012, month: 10, total: 1)

      event = response[:events].first

      expect(event[:event_csl]['author']).to eq([{"family"=>"Spoetnik", "given"=>"Laika"}])
      expect(event[:event_csl]['title']).to eq("Why Publishing in the NEJM is not the Best Guarantee that Something is True: a Response to Katan")
      expect(event[:event_csl]['container-title']).to eq("Laika's Medliblog")
      expect(event[:event_csl]['issued']).to eq("date-parts"=>[[2012, 10, 27]])
      expect(event[:event_csl]['type']).to eq("post")

      expect(event[:event_time]).to eq("2012-10-27T11:32:09Z")
      expect(event[:event_url]).to eq(event[:event]["post_URL"])
    end

    it "should catch timeout errors with the ResearchBlogging API" do
      result = { error: "the server responded with status 408 for http://researchbloggingconnect.com/blogposts?count=100&work=doi:#{work.doi_escaped}", status: 408 }
      response = subject.parse_data(result, work)
      expect(response).to eq(result)
    end
  end
end
