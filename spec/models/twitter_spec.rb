require 'rails_helper'

describe Twitter, :type => :model do
  subject { FactoryGirl.create(:twitter) }

  let(:work) { FactoryGirl.build(:work, canonical_url: "http://www.plosone.org/work/info%3Adoi%2F10.1371%2Fjournal.pmed.0020124", published_on: "2012-05-03") }

  context "get_data" do
    it "should report that there are no events if the doi is missing" do
      work = FactoryGirl.build(:work, :doi => nil)
      expect(subject.get_data(work)).to eq({})
    end

    it "should report if there are no events and event_count returned by the Twitter API" do
      work = FactoryGirl.build(:work, :doi => "10.1371/journal.pone.0044294")
      body = File.read(fixture_path + 'twitter_nil.json', encoding: 'UTF-8')
      stub = stub_request(:get, subject.get_query_url(work)).to_return(:body => body)
      response = subject.get_data(work)
      expect(response).to eq(JSON.parse(body))
      expect(stub).to have_been_requested
    end

    it "should report if there are events and event_count returned by the Twitter API" do
      body = File.read(fixture_path + 'twitter.json')
      stub = stub_request(:get, subject.get_query_url(work)).to_return(:body => body)
      response = subject.get_data(work)
      expect(response).to eq(JSON.parse(body))
      expect(stub).to have_been_requested
    end

    it "should catch errors with the Twitter API" do
      stub = stub_request(:get, subject.get_query_url(work)).to_return(:status => [408])
      response = subject.get_data(work, options = { :source_id => subject.id })
      expect(response).to eq(error: "the server responded with status 408 for http://example.org?doi=#{work.doi_escaped}", :status=>408)
      expect(stub).to have_been_requested
      expect(Alert.count).to eq(1)
      alert = Alert.first
      expect(alert.class_name).to eq("Net::HTTPRequestTimeOut")
      expect(alert.status).to eq(408)
      expect(alert.source_id).to eq(subject.id)
    end
  end

  context "parse_data" do
    it "should report if there are no events and event_count returned by the Twitter API" do
      body = File.read(fixture_path + 'twitter_nil.json', encoding: 'UTF-8')
      result = JSON.parse(body)
      response = subject.parse_data(result, work)
      expect(response).to eq(:events=>[], :events_by_day=>[], :events_by_month=>[], :events_url=>nil, :event_count=>0, :event_metrics=>{:pdf=>nil, :html=>nil, :shares=>nil, :groups=>nil, :comments=>0, :likes=>nil, :citations=>nil, :total=>0})
    end

    it "should report if there are events and event_count returned by the Twitter API" do
      body = File.read(fixture_path + 'twitter.json')
      result = JSON.parse(body)
      response = subject.parse_data(result, work)
      expect(response[:event_count]).to eq(2)

      expect(response[:events_by_day].length).to eq(2)
      expect(response[:events_by_day].first).to eq(year: 2012, month: 5, day: 20, total: 1)
      expect(response[:events_by_month].length).to eq(1)
      expect(response[:events_by_month].first).to eq(year: 2012, month: 5, total: 2)

      event = response[:events].first

      expect(event[:event_csl]['author']).to eq([{"family"=>"Regrum", "given"=>""}])
      expect(event[:event_csl]['title']).to eq("Don't be blinded by science http://t.co/YOWRhsXb")
      expect(event[:event_csl]['container-title']).to eq("Twitter")
      expect(event[:event_csl]['issued']).to eq("date-parts"=>[[2012, 5, 20]])
      expect(event[:event_csl]['type']).to eq("personal_communication")

      expect(event[:event_url]).to eq("http://twitter.com/regrum/status/204270013081849857")
      expect(event[:event_time]).to eq("2012-05-20T17:59:00Z")
      event_data = event[:event]

      expect(event_data[:id]).to eq("204270013081849857")
      expect(event_data[:text]).to eq("Don't be blinded by science http://t.co/YOWRhsXb")
      expect(event_data[:created_at]).to eq("2012-05-20T17:59:00Z")
      expect(event_data[:user]).to eq("regrum")
      expect(event_data[:user_name]).to eq("regrum")
      expect(event_data[:user_profile_image]).to eq("http://a0.twimg.com/profile_images/61215276/regmanic2_normal.JPG")
    end

    it "should catch timeout errors with the Twitter API" do
      work = FactoryGirl.create(:work, :doi => "10.2307/683422")
      result = { error: "the server responded with status 408 for http://example.org?doi=#{work.doi_escaped}", status: 408 }
      response = subject.parse_data(result, work)
      expect(response).to eq(result)
    end
  end
end
