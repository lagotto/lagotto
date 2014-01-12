# encoding: UTF-8

require 'spec_helper'

describe TwitterSearch do
  let(:twitter_search) { FactoryGirl.create(:twitter_search) }

  it "should report that there are no events if the doi is missing" do
    article = FactoryGirl.build(:article, :doi => "")
    twitter_search.get_data(article).should eq({ :events => [], :event_count => nil })
  end

  context "lookup original URL" do

    it "should look up original URL if there is no article url" do
      article = FactoryGirl.build(:article, :doi => "10.1371/journal.pone.0043007", :url => nil)
      lookup_stub = stub_request(:head, article.doi_as_url).to_return(:status => 404)
      response = twitter_search.get_data(article)
      lookup_stub.should have_been_requested
    end

    it "should not look up original URL if there is article url" do
      article = FactoryGirl.build(:article, :doi => "10.1371/journal.pone.0043007", :url => "http://www.plosone.org/article/info%3Adoi%2F10.1371%2Fjournal.pone.0043007")
      lookup_stub = stub_request(:head, article.url).to_return(:status => 200, :headers => { 'Location' => article.url })
      stub = stub_request(:get, twitter_search.get_query_url(article)).to_return(:headers => { "Content-Type" => "application/json" }, :body => File.read(fixture_path + 'twitter_search.json'), :status => 200)
      response = twitter_search.get_data(article)
      lookup_stub.should_not have_been_requested
      stub.should have_been_requested
    end
  end

  context "use the twitter_search API" do
    it "should report if there are no events and event_count returned by the twitter_search API" do
      article = FactoryGirl.build(:article, :url => "http://www.plosone.org/article/info:doi/10.1371/journal.pone.0000000")
      stub = stub_request(:get, twitter_search.get_query_url(article)).to_return(:headers => { "Content-Type" => "application/json" }, :body => File.read(fixture_path + 'twitter_search_nil.json', encoding: 'UTF-8'), :status => 200)
      twitter_search.get_data(article).should eq({:events=>[], :event_count=>0, :events_url=>"https://twitter.com/search?q=#{article.url}", :event_metrics=>{:pdf=>nil, :html=>nil, :shares=>nil, :groups=>nil, :comments=>0, :likes=>nil, :citations=>nil, :total=>0}})
      stub.should have_been_requested
    end

    it "should report if there are events and event_count returned by the twitter_search API" do
      article = FactoryGirl.build(:article, :url => "http://www.plosone.org/article/info:doi/10.1371/journal.pone.0061981")
      stub = stub_request(:get, twitter_search.get_query_url(article)).to_return(:headers => { "Content-Type" => "application/json" }, :body => File.read(fixture_path + 'twitter_search.json', encoding: 'UTF-8'), :status => 200)
      response = twitter_search.get_data(article)
      response[:events].length.should eq(15)
      response[:event_count].should eq(15)
      response[:event_metrics][:comments].should eq(15)
      response[:events_url].should eq("https://twitter.com/search?q=#{article.url}")
      event = response[:events].first
      event[:event_url].should eq("http://twitter.com/i486DX2WB/status/422133526704979968")
      stub.should have_been_requested
    end

    it "should catch errors with the twitter_search API" do
      article = FactoryGirl.build(:article, :url => "http://www.plosone.org/article/info:doi/10.1371/journal.pone.0000001")
      stub = stub_request(:get, twitter_search.get_query_url(article)).to_return(:status => [408])
      twitter_search.get_data(article, options = { :source_id => twitter_search.id }).should be_nil
      stub.should have_been_requested
      Alert.count.should == 1
      alert = Alert.first
      alert.class_name.should eq("Net::HTTPRequestTimeOut")
      alert.status.should == 408
      alert.source_id.should == twitter_search.id
    end
  end
end