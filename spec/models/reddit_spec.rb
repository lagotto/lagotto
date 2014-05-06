# encoding: UTF-8

require 'spec_helper'

describe Reddit do
  subject { FactoryGirl.create(:reddit) }

  context "get_data" do
    it "should report that there are no events if the doi is missing" do
      article = FactoryGirl.build(:article, :doi => nil)
      subject.get_data(article).should eq({})
    end

    it "should report if there are no events and event_count returned by the Reddit API" do
      article = FactoryGirl.build(:article, :doi => "10.1371/journal.pone.0044294")
      body = File.read(fixture_path + 'reddit_nil.json', encoding: 'UTF-8')
      stub = stub_request(:get, subject.get_query_url(article)).to_return(:body => body)
      response = subject.get_data(article)
      response.should eq(JSON.parse(body))
      stub.should have_been_requested
    end

    it "should report if there are events and event_count returned by the Reddit API" do
      article = FactoryGirl.build(:article, :doi => "10.1371/journal.pone.0008776")
      body = File.read(fixture_path + 'reddit.json', encoding: 'UTF-8')
      stub = stub_request(:get, subject.get_query_url(article)).to_return(:body => body)
      response = subject.get_data(article)
      response.should eq(JSON.parse(body))
      stub.should have_been_requested
    end

    it "should catch errors with the Reddit API" do
      article = FactoryGirl.build(:article, :doi => "10.1371/journal.pone.0000001")
      stub = stub_request(:get, subject.get_query_url(article)).to_return(:status => [408])
      response = subject.get_data(article, options = { :source_id => subject.id })
      response.should eq(error: "the server responded with status 408 for http://www.reddit.com/search.json?q=\"#{article.doi_escaped}\"&limit=100")
      stub.should have_been_requested
      Alert.count.should == 1
      alert = Alert.first
      alert.class_name.should eq("Net::HTTPRequestTimeOut")
      alert.status.should == 408
      alert.source_id.should == subject.id
    end
  end

  context "parse_data" do
    it "should report if the doi is missing" do
      article = FactoryGirl.build(:article, :doi => nil)
      result = {}
      result.extend Hashie::Extensions::DeepFetch
      subject.parse_data(result, article).should eq(:events=>[], :events_by_day=>[], :events_by_month=>[], :events_url=>nil, :event_count=>0, :event_metrics=>{:pdf=>nil, :html=>nil, :shares=>nil, :groups=>nil, :comments=>0, :likes=>0, :citations=>nil, :total=>0})
    end

    it "should report if there are no events and event_count returned by the Reddit API" do
      article = FactoryGirl.build(:article, :doi => "10.1371/journal.pone.0044294")
      body = File.read(fixture_path + 'reddit_nil.json', encoding: 'UTF-8')
      result = JSON.parse(body)
      result.extend Hashie::Extensions::DeepFetch
      response = subject.parse_data(result, article)
      response.should eq(events: [], event_count: 0, :events_by_day=>[], :events_by_month=>[], events_url: "http://www.reddit.com/search?q=\"#{article.doi_escaped}\"", event_metrics: { pdf: nil, html: nil, shares: nil, groups: nil, comments: 0, likes: 0, citations: nil, total: 0 })
    end

    it "should report if there are events and event_count returned by the Reddit API" do
      article = FactoryGirl.build(:article, :doi => "10.1371/journal.pone.0008776", published_on: "2013-05-03")
      body = File.read(fixture_path + 'reddit.json', encoding: 'UTF-8')
      result = JSON.parse(body)
      result.extend Hashie::Extensions::DeepFetch
      response = subject.parse_data(result, article)
      response[:events].length.should eq(3)
      response[:event_count].should eq(1171)
      response[:event_metrics][:likes].should eq(1013)
      response[:event_metrics][:comments].should eq(158)
      response[:events_url].should eq("http://www.reddit.com/search?q=\"#{article.doi_escaped}\"")

      response[:events_by_day].length.should eq(2)
      response[:events_by_day].first.should eq(year: 2013, month: 5, day: 7, total: 1)
      response[:events_by_month].length.should eq(2)
      response[:events_by_month].first.should eq(year: 2013, month: 5, total: 2)

      event = response[:events].first

      event[:event_csl]['author'].should eq([{"family"=>"jjberg2", "given"=>""}])
      event[:event_csl]['title'].should eq("AskScience AMA: We are the authors of a recent paper on genetic genealogy and relatedness among the people of Europe. Ask us anything about our paper!")
      event[:event_csl]['container-title'].should eq("Reddit")
      event[:event_csl]['issued'].should eq("date_parts"=>[2013, 5, 15])
      event[:event_csl]['type'].should eq("personal_communication")

      event[:event_time].should eq("2013-05-15T17:06:24Z")
      event[:event_url].should eq(event[:event]['url'])
    end

    it "should catch timeout errors with the Reddit API" do
      article = FactoryGirl.create(:article, :doi => "10.2307/683422")
      result = { error: "the server responded with status 408 for http://www.reddit.com/search.json?q=\"#{article.doi_escaped}\"" }
      response = subject.parse_data(result, article)
      response.should eq(result)
    end
  end
end
