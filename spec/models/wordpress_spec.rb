require 'rails_helper'

describe Wordpress, :type => :model do
  subject { FactoryGirl.create(:wordpress) }

  let(:article) { FactoryGirl.build(:article, :doi => "10.1371/journal.pone.0008776", published_on: "2007-07-01") }

  context "get_data" do
    it "should report that there are no events if the doi is missing" do
      article = FactoryGirl.build(:article, :doi => nil)
      expect(subject.get_data(article)).to eq({})
    end

    it "should report if there are no events and event_count returned by the Wordpress API" do
      article = FactoryGirl.build(:article, :doi => "10.1371/journal.pone.0044294")
      body = File.read(fixture_path + 'wordpress_nil.json', encoding: 'UTF-8')
      stub = stub_request(:get, subject.get_query_url(article)).to_return(:body => body)
      response = subject.get_data(article)
      expect(response).to eq('data' => body)
      expect(stub).to have_been_requested
    end

    it "should report if there are events and event_count returned by the Wordpress API" do
      body = File.read(fixture_path + 'wordpress.json', encoding: 'UTF-8')
      stub = stub_request(:get, subject.get_query_url(article)).to_return(:body => body)
      response = subject.get_data(article)
      expect(response).to eq('data' => JSON.parse(body))
      expect(stub).to have_been_requested
    end

    it "should catch errors with the Wordpress API" do
      article = FactoryGirl.build(:article, :doi => "10.1371/journal.pone.0000001")
      stub = stub_request(:get, subject.get_query_url(article)).to_return(:status => [408])
      response = subject.get_data(article, options = { :source_id => subject.id })
      expect(response).to eq(error: "the server responded with status 408 for http://en.search.wordpress.com/?q=\"#{article.doi_escaped}\"&t=post&f=json&size=20", :status=>408)
      expect(stub).to have_been_requested
      expect(Alert.count).to eq(1)
      alert = Alert.first
      expect(alert.class_name).to eq("Net::HTTPRequestTimeOut")
      expect(alert.status).to eq(408)
      expect(alert.source_id).to eq(subject.id)
    end
  end

  context "parse_data" do
    it "should report that there are no events if the doi is missing" do
      article = FactoryGirl.build(:article, :doi => nil)
      result = {}
      response = subject.parse_data(result, article)
      expect(response).to eq(:events=>[], :events_by_day=>[], :events_by_month=>[], :events_url=>nil, :event_count=>0, :event_metrics=>{:pdf=>nil, :html=>nil, :shares=>nil, :groups=>nil, :comments=>nil, :likes=>nil, :citations=>0, :total=>0})
    end

    it "should report if there are no events and event_count returned by the Wordpress API" do
      article = FactoryGirl.build(:article, :doi => "10.1371/journal.pone.0044294")
      result = { 'data' => "null\n" }
      response = subject.parse_data(result, article)
      expect(response).to eq(:events=>[], :events_by_day=>[], :events_by_month=>[], :events_url=>"http://en.search.wordpress.com/?q=\"#{article.doi_escaped}\"&t=post", :event_count=>0, :event_metrics=>{:pdf=>nil, :html=>nil, :shares=>nil, :groups=>nil, :comments=>nil, :likes=>nil, :citations=>0, :total=>0})
    end

    it "should report if there are events and event_count returned by the Wordpress API" do
      body = File.read(fixture_path + 'wordpress.json', encoding: 'UTF-8')
      result = { 'data' => JSON.parse(body) }
      response = subject.parse_data(result, article)
      expect(response[:events_url]).to eq("http://en.search.wordpress.com/?q=\"#{article.doi_escaped}\"&t=post")

      expect(response[:events_by_day].length).to eq(1)
      expect(response[:events_by_day].first).to eq(year: 2007, month: 7, day: 12, total: 1)
      expect(response[:events_by_month].length).to eq(6)
      expect(response[:events_by_month].first).to eq(year: 2007, month: 7, total: 1)

      event = response[:events].first

      expect(event[:event_csl]['author']).to eq([{"family"=>"Piwowar", "given"=>"Heather"}])
      expect(event[:event_csl]['title']).to eq("Presentation on Citation Rate for Shared Data")
      expect(event[:event_csl]['container-title']).to eq("")
      expect(event[:event_csl]['issued']).to eq("date-parts"=>[[2007, 7, 12]])
      expect(event[:event_csl]['type']).to eq("post")

      expect(event[:event_time]).to eq("2007-07-12T15:36:38Z")
      expect(event[:event_url]).to eq(event[:event]['link'])
    end

    it "should catch timeout errors with the Wordpress API" do
      article = FactoryGirl.create(:article, :doi => "10.2307/683422")
      result = { error: "the server responded with status 408 for http://en.search.wordpress.com/?q=\"#{article.doi_escaped}\"&t=post&f=json&size=20", status: 408 }
      response = subject.parse_data(result, article)
      expect(response).to eq(result)
    end
  end
end
