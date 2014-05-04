require 'spec_helper'

describe Citeulike do
  subject { FactoryGirl.create(:citeulike) }

  let(:article) { FactoryGirl.build(:article, :doi => "10.1371/journal.pone.0008776", published_on: "2006-06-01") }

  context "get_data" do
    it "should report that there are no events if the doi is missing" do
      article = FactoryGirl.build(:article, :doi => nil)
      subject.get_data(article).should eq({})
    end

    it "should report if there are no events and event_count returned by the CiteULike API" do
      body = File.read(fixture_path + 'citeulike_nil.xml')
      stub = stub_request(:get, subject.get_query_url(article)).to_return(:body => body, :status => 200)
      response = subject.get_data(article)
      response.should eq(Hash.from_xml(body))
      stub.should have_been_requested
    end

    it "should report if there are events and event_count returned by the CiteULike API" do
      body = File.read(fixture_path + 'citeulike.xml')
      stub = stub_request(:get, subject.get_query_url(article)).to_return(:body => body, :status => 200)
      response = subject.get_data(article)
      response.should eq(Hash.from_xml(body))
      stub.should have_been_requested
    end

    it "should catch errors with the CiteULike API" do
      stub = stub_request(:get, subject.get_query_url(article)).to_return(:status => [408])
      response = subject.get_data(article, source_id: subject.id)
      response.should eq(error: "the server responded with status 408 for http://www.citeulike.org/api/posts/for/doi/#{article.doi_escaped}")
      stub.should have_been_requested
      Alert.count.should == 1
      alert = Alert.first
      alert.class_name.should eq("Net::HTTPRequestTimeOut")
      alert.status.should == 408
      alert.source_id.should == subject.id
    end
  end

  context "parse_data" do
    let(:null_response) { { events: [], :events_by_day=>[], :events_by_month=>[], events_url: subject.get_events_url(article), event_count: 0, event_metrics: { pdf: nil, html: nil, shares: 0, groups: nil, comments: nil, likes: nil, citations: nil, total: 0 } } }

    it "should report if the doi is missing" do
      article = FactoryGirl.build(:article, :doi => nil)
      result = {}
      result.extend Hashie::Extensions::DeepFetch
      subject.parse_data(result, article).should eq(events: [], :events_by_day=>[], :events_by_month=>[], events_url: nil, event_count: 0, event_metrics: { pdf: nil, html: nil, shares: 0, groups: nil, comments: nil, likes: nil, citations: nil, total: 0 })
    end

    it "should report if there are no events and event_count returned by the CiteULike API" do
      result = { "posts" => nil }
      result.extend Hashie::Extensions::DeepFetch
      subject.parse_data(result, article).should eq(null_response)
    end

    it "should report if there are events and event_count returned by the CiteULike API" do
      body = File.read(fixture_path + 'citeulike.xml')
      result = Hash.from_xml(body)
      result.extend Hashie::Extensions::DeepFetch

      response = subject.parse_data(result, article)
      response[:events].length.should eq(25)
      response[:events_by_month].length.should eq(21)
      response[:events_by_month].first.should eq(year: 2006, month: 6, total: 2)
      response[:events_url].should eq(subject.get_events_url(article))
      response[:event_count].should eq(25)
      event = response[:events].first
      event[:event_time].should eq("2006-06-13T16:14:19Z")
      event[:event_url].should eq(event[:event]['link']['url'])
    end

    it "should report if there is one event returned by the CiteULike API" do
      body = File.read(fixture_path + 'citeulike_one.xml')
      result = Hash.from_xml(body)
      result.extend Hashie::Extensions::DeepFetch

      response = subject.parse_data(result, article)
      response[:events].length.should eq(1)
      response[:events_by_month].length.should eq(1)
      response[:events_by_month].first.should eq(year: 2006, month: 6, total: 1)
      response[:events_url].should eq(subject.get_events_url(article))
      response[:event_count].should eq(1)
      event = response[:events].first
      event[:event_time].should eq("2006-06-13T16:14:19Z")
      event[:event_url].should eq(event[:event]['link']['url'])
    end

    it "should catch timeout errors with the CiteULike API" do
      result = { error: "the server responded with status 408 for http://www.citeulike.org/api/posts/for/doi/#{article.doi_escaped}" }
      response = subject.parse_data(result, article)
      response.should eq(result)
    end
  end
end
