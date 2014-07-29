require 'spec_helper'

describe Nature do
  subject { FactoryGirl.create(:nature) }

  let(:article) { FactoryGirl.build(:article, doi: "10.1371/journal.pone.0008776", published_on: "2009-09-01") }

  context "get_data" do
    it "should report that there are no events if the doi is missing" do
      article = FactoryGirl.build(:article, :doi => nil)
      subject.get_data(article).should eq({})
    end

    it "should report if there are no events and event_count returned by the Nature Blogs API" do
      article = FactoryGirl.build(:article, :doi => "10.1371/journal.pone.0044294")
      body = File.read(fixture_path + 'nature_nil.json')
      stub = stub_request(:get, subject.get_query_url(article)).to_return(:body => body)
      response = subject.get_data(article)
      response.should eq('data' => JSON.parse(body))
      stub.should have_been_requested
    end

    it "should report if there are events and event_count returned by the Nature Blogs API" do
      body = File.read(fixture_path + 'nature.json')
      stub = stub_request(:get, subject.get_query_url(article)).to_return(:body => body)
      response = subject.get_data(article)
      response.should eq('data' => JSON.parse(body))
      stub.should have_been_requested
    end

    it "should catch timeout errors with the Nature Blogs API" do
      article = FactoryGirl.build(:article, :doi => "10.1371/journal.pone.0000001")
      stub = stub_request(:get, subject.get_query_url(article)).to_return(:status => [408])
      response = subject.get_data(article, options = { :source_id => subject.id })
      response.should eq(error: "the server responded with status 408 for http://blogs.nature.com/posts.json?doi=#{article.doi_escaped}", :status=>408)
      stub.should have_been_requested
      Alert.count.should == 1
      alert = Alert.first
      alert.class_name.should eq("Net::HTTPRequestTimeOut")
      alert.status.should == 408
      alert.source_id.should == subject.id
    end
  end

  context "parse_data" do
    let(:null_response) { { events: [], :events_by_day=>[], :events_by_month=>[], :events_url=>nil, event_count: 0, event_metrics: { pdf: nil, html: nil, shares: nil, groups: nil, comments: nil, likes: nil, citations: 0, total: 0 } } }

    it "should report if the doi is missing" do
      article = FactoryGirl.build(:article, :doi => nil)
      result = {}
      subject.parse_data(result, article).should eq(null_response)
    end

    it "should report if there are no events and event_count returned by the Nature Blogs API" do
      body = File.read(fixture_path + 'nature_nil.json')
      result = { 'data' => JSON.parse(body) }
      response = subject.parse_data(result, article)
      response.should eq(null_response)
    end

    it "should report if there are events and event_count returned by the Nature Blogs API" do
      body = File.read(fixture_path + 'nature.json')
      result = { 'data' => JSON.parse(body) }
      response = subject.parse_data(result, article)
      response[:event_count].should eq(10)

      response[:events_by_day].length.should eq(1)
      response[:events_by_day].first.should eq(year: 2009, month: 9, day: 18, total: 1)
      response[:events_by_month].length.should eq(9)
      response[:events_by_month].first.should eq(year: 2009, month: 9, total: 1)

      event = response[:events].first

      event[:event_csl]['author'].should eq("")
      event[:event_csl]['title'].should eq("More Impact Factor spam from Nature")
      event[:event_csl]['container-title'].should eq("bjoern.brembs.blog : a neuroscientist's blog")
      event[:event_csl]['issued'].should eq("date_parts"=>[2012, 6, 19])
      event[:event_csl]['type'].should eq("post")

      event[:event_time].should eq("2012-06-19T16:40:23Z")
      event[:event_url].should_not be_nil
    end

    it "should catch timeout errors with the Nature Blogs APi" do
      article = FactoryGirl.create(:article, :doi => "10.1371/journal.pone.0000001")
      result = { error: "the server responded with status 408 for http://blogs.nature.com/posts.json?doi=#{article.doi_escaped}", status: 408 }
      response = subject.parse_data(result, article)
      response.should eq(result)
    end
  end
end
