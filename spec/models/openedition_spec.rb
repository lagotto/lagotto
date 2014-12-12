require 'rails_helper'

describe Openedition, :type => :model do
  subject { FactoryGirl.create(:openedition) }

  context "get_data" do
    it "should report that there are no events if the doi is missing" do
      work = FactoryGirl.build(:work, :doi => nil)
      expect(subject.get_data(work)).to eq({})
    end

    it "should report if there are no events and event_count returned by the Openedition API" do
      work = FactoryGirl.build(:work, :doi => "10.1371/journal.pone.0000001")
      body = File.read(fixture_path + 'openedition_nil.xml')
      stub = stub_request(:get, subject.get_query_url(work)).to_return(:body => body)
      response = subject.get_data(work)
      expect(response).to eq(Hash.from_xml(body))
      expect(stub).to have_been_requested
    end

    it "should report if there are events and event_count returned by the Openedition API" do
      work = FactoryGirl.build(:work, :doi => "10.2307/683422")
      body = File.read(fixture_path + 'openedition.xml')
      stub = stub_request(:get, subject.get_query_url(work)).to_return(:body => body)
      response = subject.get_data(work)
      expect(response).to eq(Hash.from_xml(body))
      expect(stub).to have_been_requested
    end

    it "should catch errors with the Openedition API" do
      work = FactoryGirl.build(:work, :doi => "10.2307/683422")
      stub = stub_request(:get, subject.get_query_url(work)).to_return(:status => [408])
      response = subject.get_data(work, options = { :source_id => subject.id })
      expect(response).to eq(error: "the server responded with status 408 for http://search.openedition.org/feed.php?op[]=AND&q[]=#{work.doi_escaped}&field[]=All&pf=Hypotheses.org", :status=>408)
      expect(stub).to have_been_requested
      expect(Alert.count).to eq(1)
      alert = Alert.first
      expect(alert.class_name).to eq("Net::HTTPRequestTimeOut")
      expect(alert.status).to eq(408)
      expect(alert.source_id).to eq(subject.id)
    end
  end

  context "parse_data" do
    let(:work) { FactoryGirl.build(:work, :doi => "10.1371/journal.pone.0000001") }
    let(:null_response) { { events: [], :events_by_day=>[], :events_by_month=>[], events_url: "http://search.openedition.org/index.php?op[]=AND&q[]=#{work.doi_escaped}&field[]=All&pf=Hypotheses.org", event_count: 0, event_metrics: { pdf: nil, html: nil, shares: nil, groups: nil, comments: nil, likes: nil, citations: 0, total: 0 } } }

    it "should report if the doi is missing" do
      work = FactoryGirl.build(:work, :doi => nil)
      result = {}
      result.extend Hashie::Extensions::DeepFetch
      expect(subject.parse_data(result, work)).to eq(events: [], :events_by_day=>[], :events_by_month=>[], events_url: nil, event_count: 0, event_metrics: { pdf: nil, html: nil, shares: nil, groups: nil, comments: nil, likes: nil, citations: 0, total: 0 })
    end

    it "should report if there are no events and event_count returned by the Openedition API" do
      body = File.read(fixture_path + 'openedition_nil.xml')
      result = Hash.from_xml(body)
      result.extend Hashie::Extensions::DeepFetch
      response = subject.parse_data(result, work)
      expect(response).to eq(null_response)
    end

    it "should report if there are events and event_count returned by the Openedition API" do
      work = FactoryGirl.build(:work, :doi => "10.2307/683422", published_on: "2013-05-03")
      body = File.read(fixture_path + 'openedition.xml')
      result = Hash.from_xml(body)
      result.extend Hashie::Extensions::DeepFetch
      response = subject.parse_data(result, work)
      expect(response[:event_count]).to eq(1)
      expect(response[:events_url]).to eq("http://search.openedition.org/index.php?op[]=AND&q[]=#{work.doi_escaped}&field[]=All&pf=Hypotheses.org")

      expect(response[:events_by_day].length).to eq(1)
      expect(response[:events_by_day].first).to eq(year: 2013, month: 5, day: 27, total: 1)
      expect(response[:events_by_month].length).to eq(1)
      expect(response[:events_by_month].first).to eq(year: 2013, month: 5, total: 1)

      event = response[:events].first
      expect(event[:event_time]).to eq("2013-05-27T00:00:00Z")
      expect(event[:event_url]).to eq(event[:event]['link'])
    end

    it "should catch timeout errors with the OpenEdition APi" do
      work = FactoryGirl.create(:work, :doi => "10.2307/683422")
      result = { error: "the server responded with status 408 for http://search.openedition.org/feed.php?op[]=AND&q[]=#{work.doi_escaped}&field[]=All&pf=Hypotheses.org", status: 408 }
      response = subject.parse_data(result, work)
      expect(response).to eq(result)
    end
  end
end
