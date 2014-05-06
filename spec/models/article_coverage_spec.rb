require 'spec_helper'

describe ArticleCoverage do
  subject { FactoryGirl.create(:article_coverage) }

  let(:article) { FactoryGirl.build(:article, :doi => "10.1371/journal.pone.0047712", published_on: "2013-11-01") }

  it "should report that there are no events if the doi is missing" do
    article = FactoryGirl.build(:article, :doi => nil)
    subject.get_data(article).should eq({})
  end

  it "should report that there are no events if the doi has the wrong prefix" do
    article = FactoryGirl.build(:article, :doi => "10.5194/acp-12-12021-2012")
    subject.get_data(article).should eq({})
  end

  context "get_data from the Article Coverage API" do
    it "should report if article doesn't exist in Article Coverage source" do
      article = FactoryGirl.build(:article, :doi => "10.1371/journal.pone.0008776")
      stub = stub_request(:get, subject.get_query_url(article)).to_return(:body => {"error" => "Article not found"}.to_json, :status => 404)
      subject.get_data(article).should eq(error: "Article not found")
      stub.should have_been_requested
    end

    it "should report if there are no events and event_count returned by the Article Coverage API" do
      article = FactoryGirl.build(:article, :doi => "10.1371/journal.pone.0008775")
      body = File.read(fixture_path + 'article_coverage_curated_nil.json')
      stub = stub_request(:get, subject.get_query_url(article)).to_return(:body => body)
      response = subject.get_data(article)
      response.should eq(JSON.parse(body))
      stub.should have_been_requested
    end

    it "should report if there are events and event_count returned by the Article Coverage API" do
      body = File.read(fixture_path + 'article_coverage.json')
      stub = stub_request(:get, subject.get_query_url(article)).to_return(:body => body)
      response = subject.get_data(article)
      response.should eq(JSON.parse(body))
      stub.should have_been_requested
    end

    it "should catch timeout errors with the Article Coverage API" do
      stub = stub_request(:get, subject.get_query_url(article)).to_return(:status => [408])
      response = subject.get_data(article, options = { :source_id => subject.id })
      response.should eq(error: "the server responded with status 408 for http://example.org?doi=#{article.doi_escaped}")
      stub.should have_been_requested
      Alert.count.should == 1
      alert = Alert.first
      alert.class_name.should eq("Net::HTTPRequestTimeOut")
      alert.status.should == 408
      alert.source_id.should == subject.id
    end
  end

  context "parse_data from the Article Coverage API" do
    it "should report if the doi is missing" do
      article = FactoryGirl.build(:article, :doi => nil)
      result = {}
      subject.parse_data(result, article).should eq(:events=>[], :events_by_day=>[], :events_by_month=>[], :events_url=>nil, :event_count=>0, :event_metrics=>{:pdf=>nil, :html=>nil, :shares=>nil, :groups=>nil, :comments=>0, :likes=>nil, :citations=>nil, :total=>0})
    end

    it "should report if article doesn't exist in Article Coverage source" do
      result = { error: "{\"error\":\"Article not found\"}" }
      response = subject.parse_data(result, article)
      response.should eq(result)
    end

    it "should report if there are no events and event_count returned by the Article Coverage API" do
      body = File.read(fixture_path + 'article_coverage_curated_nil.json')
      result = JSON.parse(body)
      response = subject.parse_data(result, article)
      response.should eq(:events=>[], :events_by_day=>[], :events_by_month=>[], :events_url=>nil, :event_count=>0, :event_metrics=>{:pdf=>nil, :html=>nil, :shares=>nil, :groups=>nil, :comments=>0, :likes=>nil, :citations=>nil, :total=>0})
    end

    it "should report if there are events and event_count returned by the Article Coverage API" do
      body = File.read(fixture_path + 'article_coverage.json')
      result = JSON.parse(body)
      response = subject.parse_data(result, article)
      response[:events].length.should eq(2)

      response[:events_by_day].length.should eq(1)
      response[:events_by_day].first.should eq(year: 2013, month: 11, day: 20, total: 2)
      response[:events_by_month].length.should eq(1)
      response[:events_by_month].first.should eq(year: 2013, month: 11, total: 2)

      response[:event_count].should eq(2)
      event = response[:events].first
      event_data = event[:event]
      event_data['referral'].should eq("http://www.huffingtonpost.com/2013/11/08/personal-hygiene-facts_n_4217839.html")
      event_data['language'].should eq("English")
      event_data['title'].should eq("Everything You Know About Your Personal Hygiene Is Wrong")
      event_data['type'].should eq("Blog")
      event_data['publication'].should eq("The Huffington Post")
      event_data['published_on'].should eq("2013-11-20T00:00:00Z")
      event_data['link_state'].should eq("APPROVED")

      event[:event_time].should eq("2013-11-20T00:00:00Z")
      event[:event_url].should eq("http://www.huffingtonpost.com/2013/11/08/personal-hygiene-facts_n_4217839.html")
    end

    it "should catch timeout errors with the Article Coverage API" do
      result = { error: "the server responded with status 408 for http://example.org?doi=#{article.doi_escaped}" }
      response = subject.parse_data(result, article)
      response.should eq(result)
    end
  end
end
