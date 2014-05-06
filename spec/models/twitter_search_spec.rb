# encoding: UTF-8

require 'spec_helper'

describe TwitterSearch do
  subject { FactoryGirl.create(:twitter_search) }

  it "should set the since_id for an article" do
    article = FactoryGirl.create(:article_with_tweets, :doi => "10.1371/journal.pone.0043007")
    since_id = 8
    subject.set_since_id(article, since_id: since_id)
    subject.get_since_id(article).should eq(since_id)
  end

  it "should get the next max_id from a response" do
    response = JSON.parse(File.read(fixture_path + 'twitter_search_paged.json', encoding: 'UTF-8'))
    max_id = subject.get_max_id(response["search_metadata"]["next_results"])
    max_id.should eq("422081966914428927")
  end

  # context "lookup original URL" do

  #   it "should look up original URL if there is no article url" do
  #     article = FactoryGirl.create(:article_with_tweets, :doi => "10.1371/journal.pone.0043007", :url => nil)
  #     lookup_stub = stub_request(:head, article.doi_as_url).to_return(:status => 404)
  #     response = twitter_search.parse_data(article)
  #     lookup_stub.should have_been_requested
  #   end

  #   it "should not look up original URL if there is article url" do
  #     article = FactoryGirl.create(:article_with_tweets, :doi => "10.1371/journal.pone.0043007", :url => "http://www.plosone.org/article/info%3Adoi%2F10.1371%2Fjournal.pone.0043007")
  #     lookup_stub = stub_request(:head, article.url).to_return(:status => 200, :headers => { 'Location' => article.url })
  #     stub = stub_request(:get, twitter_search.get_query_url(article)).to_return(:headers => { "Content-Type" => "application/json" }, :body => File.read(fixture_path + 'twitter_search.json'), :status => 200)
  #     other_stub = stub_request(:get, twitter_search.get_query_url(article, since_id: 422133526704979968)).to_return(:headers => { "Content-Type" => "application/json" }, :body => File.read(fixture_path + 'twitter_search_nil.json'), :status => 200)
  #     response = twitter_search.parse_data(article)
  #     lookup_stub.should_not have_been_requested
  #     stub.should have_been_requested
  #     other_stub.should have_been_requested
  #   end
  # end

  context "get_data" do
    it "should report that there are no events if the doi is missing" do
      article = FactoryGirl.build(:article, :doi => nil)
      subject.get_data(article).should eq({})
    end

    it "should report if there are no events and event_count returned by the Twitter Search API" do
      article = FactoryGirl.create(:article_with_tweets, :doi => "10.1371/journal.pone.0000000")
      body = File.read(fixture_path + 'twitter_search_nil.json', encoding: 'UTF-8')
      stub = stub_request(:get, subject.get_query_url(article)).to_return(:body => body)
      response = subject.get_data(article)
      response.should eq(JSON.parse(body))
      stub.should have_been_requested
    end

    it "should report if there are events and event_count returned by the Twitter Search API" do
      article = FactoryGirl.create(:article_with_tweets, :doi => "10.1371/journal.pmed.0020124")
      body = File.read(fixture_path + 'twitter_search.json', encoding: 'UTF-8')
      stub = stub_request(:get, subject.get_query_url(article)).to_return(:body => body)
      response = subject.get_data(article)
      response.should eq(JSON.parse(body))
      stub.should have_been_requested
    end

    it "should catch errors with the Twitter Search API" do
      article = FactoryGirl.create(:article_with_tweets, :doi => "10.1371/journal.pone.0000001")
      stub = stub_request(:get, subject.get_query_url(article)).to_return(:status => [408])
      response = subject.get_data(article, options = { :source_id => subject.id })
      response.should eq(error: "the server responded with status 408 for https://api.twitter.com/1.1/search/tweets.json?count=100&include_entities=1&q=#{CGI.escape(article.doi_escaped)}&result_type=mixed")
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

      event[:event_csl]['author'].should eq([{"family"=>"ChampionsEverywhere", "given"=>""}])
      event[:event_csl]['title'].should eq("A bit technical but worth a read: randomised medical control studies may be almost entirely false:... http://t.co/ohldzDxNiq")
      event[:event_csl]['container-title'].should eq("Twitter")
      event[:event_csl]['issued'].should eq("date_parts"=>[2014, 1, 11])
      event[:event_csl]['type'].should eq("personal_communication")

      event[:event_url].should eq("http://twitter.com/ChampsEvrywhere/status/422039629882089472")
      event[:event_time].should eq("2014-01-11T16:17:43Z")
    end

    it "should catch timeout errors with the Twitter Search API" do
      article = FactoryGirl.create(:article, :doi => "10.2307/683422")
      result = { error: "the server responded with status 408 for https://api.twitter.com/1.1/search/tweets.json?count=100&include_entities=1&q=#{CGI.escape(article.doi_escaped)}&result_type=mixed" }
      response = subject.parse_data(result, article)
      response.should eq(result)
    end
  end
end
