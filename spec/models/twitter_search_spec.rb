# encoding: UTF-8

require 'spec_helper'

describe TwitterSearch do
  subject { FactoryGirl.create(:twitter_search) }

  context "lookup access token" do
    let(:auth) { ActionController::HttpAuthentication::Basic.encode_credentials(subject.api_key, subject.api_secret) }

    it "should make the right API call" do
      subject.access_token = nil
      stub = stub_request(:post, subject.authentication_url).with(:body => "grant_type=client_credentials", :headers => { :authorization => auth })
        .to_return(:body => File.read(fixture_path + 'twitter_auth.json'))
      subject.get_access_token.should be_true
      stub.should have_been_requested
      subject.access_token.should eq("AAAAAAAAAAAAAAAAAAAAACS6XQAAAAAAc7aBSzqxeYuzho78VPeXw4md79A%3DuWsDmuGGhl0tOQJuNZAl37MN6tiTiar7U8tHQkBGbkk1rvlNqk")
    end

    it "should look up access token if blank" do
      subject.access_token = nil
      article = FactoryGirl.create(:article, :doi => "10.1371/journal.pone.0043007", :canonical_url => "http://www.plosone.org/article/info%3Adoi%2F10.1371%2Fjournal.pone.0043007")
      stub_auth = stub_request(:post, subject.authentication_url).with(:headers => { :authorization => auth }, :body => "grant_type=client_credentials")
        .to_return(:body => File.read(fixture_path + 'twitter_auth.json'))
      stub = stub_request(:get, subject.get_query_url(article)).to_return(:status => [408])

      response = subject.get_data(article, source_id: subject.id)
      response[:error].should_not be_nil
      stub_auth.should have_been_requested
      stub.should have_been_requested
    end
  end

  context "lookup canonical URL" do
    it "should look up canonical URL if there is no article url" do
      article = FactoryGirl.create(:article, :doi => "10.1371/journal.pone.0043007", :canonical_url => nil)
      lookup_stub = stub_request(:get, article.doi_as_url).to_return(:status => 404)
      response = subject.get_data(article)
      lookup_stub.should have_been_requested
    end

    it "should not look up canonical URL if there is article url" do
      article = FactoryGirl.create(:article, :doi => "10.1371/journal.pone.0043007", :canonical_url => "http://www.plosone.org/article/info%3Adoi%2F10.1371%2Fjournal.pone.0043007")
      lookup_stub = stub_request(:get, article.canonical_url).to_return(:status => 200, :headers => { 'Location' => article.canonical_url })
      stub = stub_request(:get, subject.get_query_url(article)).to_return(:body => File.read(fixture_path + 'cross_ref_nil.xml'))
      response = subject.get_data(article)
      lookup_stub.should_not have_been_requested
      stub.should have_been_requested
    end
  end

  context "get_data" do
    it "should report that there are no events if the doi is missing" do
      article = FactoryGirl.build(:article, :doi => nil)
      subject.get_data(article).should eq({})
    end

    it "should report if there are no events and event_count returned by the Twitter Search API" do
      article = FactoryGirl.create(:article_with_tweets, :doi => "10.1371/journal.pone.0000000", :canonical_url => "http://www.plosone.org/article/info%3Adoi%2F10.1371%2Fjournal.pmed.0000000")
      body = File.read(fixture_path + 'twitter_search_nil.json', encoding: 'UTF-8')
      stub = stub_request(:get, subject.get_query_url(article)).to_return(:body => body)
      response = subject.get_data(article)
      response.should eq(JSON.parse(body))
      stub.should have_been_requested
    end

    it "should report if there are events and event_count returned by the Twitter Search API" do
      article = FactoryGirl.create(:article_with_tweets, :doi => "10.1371/journal.pmed.0020124", :canonical_url => "http://www.plosmedicine.org/article/info%3Adoi%2F10.1371%2Fjournal.pmed.0020124")
      body = File.read(fixture_path + 'twitter_search.json', encoding: 'UTF-8')
      stub = stub_request(:get, subject.get_query_url(article)).to_return(:body => body)
      response = subject.get_data(article)
      response.should eq(JSON.parse(body))
      stub.should have_been_requested
    end

    it "should catch errors with the Twitter Search API" do
      article = FactoryGirl.create(:article_with_tweets, :doi => "10.1371/journal.pone.0000001", :canonical_url => "http://www.plosone.org/article/info%3Adoi%2F10.1371%2Fjournal.pmed.0000001")
      stub = stub_request(:get, subject.get_query_url(article)).to_return(:status => [408])
      response = subject.get_data(article, options = { :source_id => subject.id })
      response.should eq(error: "the server responded with status 408 for https://api.twitter.com/1.1/search/tweets.json?count=100&include_entities=1&q=10.1371%252Fjournal.pone.0000001+OR+http%3A%2F%2Fwww.plosone.org%2Farticle%2Finfo%253Adoi%252F10.1371%252Fjournal.pmed.0000001&result_type=recent", :status=>408)
      stub.should have_been_requested
      Alert.count.should == 1
      alert = Alert.first
      alert.class_name.should eq("Net::HTTPRequestTimeOut")
      alert.status.should == 408
      alert.source_id.should == subject.id
    end
  end

  context "parse_data" do
    it "should report if there are no events and event_count returned by the Twitter Search API" do
      article = FactoryGirl.create(:article_with_tweets, :doi => "10.1371/journal.pone.0000000")
      body = File.read(fixture_path + 'twitter_search_nil.json', encoding: 'UTF-8')
      result = JSON.parse(body)
      subject.parse_data(result, article).should eq(events: [], :events_by_day=>[], :events_by_month=>[], event_count: 0, events_url: "https://twitter.com/search?q=#{article.doi_escaped}", event_metrics: { pdf: nil, html: nil, shares: nil, groups: nil, comments: 0, likes: nil, citations: nil, total: 0 })
    end

    it "should report if there are events and event_count returned by the Twitter Search API" do
      article = FactoryGirl.build(:article_with_tweets, :doi => "10.1371/journal.pmed.0020124", published_on: "2014-01-01")
      body = File.read(fixture_path + 'twitter_search.json', encoding: 'UTF-8')
      result = JSON.parse(body)
      response = subject.parse_data(result, article)
      response[:events].length.should == 8
      response[:event_count].should == 8
      response[:event_metrics][:comments].should == 8
      response[:events_url].should eq("https://twitter.com/search?q=#{article.doi_escaped}")

      response[:events_by_day].length.should == 6
      response[:events_by_day].first.should eq(year: 2014, month: 1, day: 6, total: 1)
      response[:events_by_month].length.should == 1
      response[:events_by_month].first.should eq(year: 2014, month: 1, total: 8)

      event = response[:events].first

      event[:event_csl]['author'].should eq([{"family"=>"Champions Everywhere", "given"=>""}])
      event[:event_csl]['title'].should eq("A bit technical but worth a read: randomised medical control studies may be almost entirely false:... http://t.co/ohldzDxNiq")
      event[:event_csl]['container-title'].should eq("Twitter")
      event[:event_csl]['issued'].should eq("date_parts"=>[2014, 1, 11])
      event[:event_csl]['type'].should eq("personal_communication")

      event[:event_url].should eq("http://twitter.com/ChampsEvrywhere/status/422039629882089472")
      event[:event_time].should eq("2014-01-11T16:17:43Z")
    end

    it "should catch timeout errors with the Twitter Search API" do
      article = FactoryGirl.create(:article, :doi => "10.2307/683422")
      result = { error: "the server responded with status 408 for https://api.twitter.com/1.1/search/tweets.json?count=100&include_entities=1&q=#{CGI.escape(article.doi_escaped)}&result_type=mixed", status: 408 }
      response = subject.parse_data(result, article)
      response.should eq(result)
    end
  end
end
