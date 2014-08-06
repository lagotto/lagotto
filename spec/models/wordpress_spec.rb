# encoding: UTF-8

require 'spec_helper'

describe Wordpress do
  subject { FactoryGirl.create(:wordpress) }

  let(:article) { FactoryGirl.build(:article, :doi => "10.1371/journal.pone.0008776", published_on: "2007-07-01") }

  context "get_data" do
    it "should report that there are no events if the doi is missing" do
      article = FactoryGirl.build(:article, :doi => nil)
      subject.get_data(article).should eq({})
    end

    it "should report if there are no events and event_count returned by the Wordpress API" do
      article = FactoryGirl.build(:article, :doi => "10.1371/journal.pone.0044294")
      body = File.read(fixture_path + 'wordpress_nil.json', encoding: 'UTF-8')
      stub = stub_request(:get, subject.get_query_url(article)).to_return(:body => body)
      response = subject.get_data(article)
      response.should eq('data' => body)
      stub.should have_been_requested
    end

    it "should report if there are events and event_count returned by the Wordpress API" do
      body = File.read(fixture_path + 'wordpress.json', encoding: 'UTF-8')
      stub = stub_request(:get, subject.get_query_url(article)).to_return(:body => body)
      response = subject.get_data(article)
      response.should eq('data' => JSON.parse(body))
      stub.should have_been_requested
    end

    it "should catch errors with the Wordpress API" do
      article = FactoryGirl.build(:article, :doi => "10.1371/journal.pone.0000001")
      stub = stub_request(:get, subject.get_query_url(article)).to_return(:status => [408])
      response = subject.get_data(article, options = { :source_id => subject.id })
      response.should eq(error: "the server responded with status 408 for http://en.search.wordpress.com/?q=\"#{article.doi_escaped}\"&t=post&f=json&size=20", :status=>408)
      stub.should have_been_requested
      Alert.count.should == 1
      alert = Alert.first
      alert.class_name.should eq("Net::HTTPRequestTimeOut")
      alert.status.should == 408
      alert.source_id.should == subject.id
    end
  end

  context "parse_data" do
    it "should report that there are no events if the doi is missing" do
      article = FactoryGirl.build(:article, :doi => nil)
      result = {}
      response = subject.parse_data(result, article)
      response.should eq(:events=>[], :events_by_day=>[], :events_by_month=>[], :events_url=>nil, :event_count=>0, :event_metrics=>{:pdf=>nil, :html=>nil, :shares=>nil, :groups=>nil, :comments=>nil, :likes=>nil, :citations=>0, :total=>0})
    end

    it "should report if there are no events and event_count returned by the Wordpress API" do
      article = FactoryGirl.build(:article, :doi => "10.1371/journal.pone.0044294")
      result = { 'data' => "null\n" }
      response = subject.parse_data(result, article)
      response.should eq(:events=>[], :events_by_day=>[], :events_by_month=>[], :events_url=>"http://en.search.wordpress.com/?q=\"#{article.doi_escaped}\"&t=post", :event_count=>0, :event_metrics=>{:pdf=>nil, :html=>nil, :shares=>nil, :groups=>nil, :comments=>nil, :likes=>nil, :citations=>0, :total=>0})
    end

    it "should report if there are events and event_count returned by the Wordpress API" do
      body = File.read(fixture_path + 'wordpress.json', encoding: 'UTF-8')
      result = { 'data' => JSON.parse(body) }
      response = subject.parse_data(result, article)
      response[:events_url].should eq("http://en.search.wordpress.com/?q=\"#{article.doi_escaped}\"&t=post")

      response[:events_by_day].length.should eq(1)
      response[:events_by_day].first.should eq(year: 2007, month: 7, day: 12, total: 1)
      response[:events_by_month].length.should eq(6)
      response[:events_by_month].first.should eq(year: 2007, month: 7, total: 1)

      event = response[:events].first

      event[:event_csl]['author'].should eq([{"family"=>"Piwowar", "given"=>"Heather"}])
      event[:event_csl]['title'].should eq("Presentation on Citation Rate for Shared Data")
      event[:event_csl]['container-title'].should eq("")
      event[:event_csl]['issued'].should eq("date-parts"=>[[2007, 7, 12]])
      event[:event_csl]['type'].should eq("post")

      event[:event_time].should eq("2007-07-12T15:36:38Z")
      event[:event_url].should eq(event[:event]['link'])
    end

    it "should catch timeout errors with the Wordpress API" do
      article = FactoryGirl.create(:article, :doi => "10.2307/683422")
      result = { error: "the server responded with status 408 for http://en.search.wordpress.com/?q=\"#{article.doi_escaped}\"&t=post&f=json&size=20", status: 408 }
      response = subject.parse_data(result, article)
      response.should eq(result)
    end
  end
end
