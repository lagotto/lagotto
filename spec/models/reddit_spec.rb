# encoding: UTF-8

require 'spec_helper'

describe Reddit do
  let(:reddit) { FactoryGirl.create(:reddit) }

  it "should report that there are no events if the doi is missing" do
    article = FactoryGirl.build(:article, :doi => "")
    reddit.get_data(article).should eq({ :events => [], :event_count => nil })
  end

  context "use the Reddit API" do
    it "should report if there are no events and event_count returned by the Reddit API" do
      article = FactoryGirl.build(:article, :doi => "10.1371/journal.pone.0044294")
      stub = stub_request(:get, reddit.get_query_url(article)).to_return(:headers => { "Content-Type" => "application/json" }, :body => File.read(fixture_path + 'reddit_nil.json', encoding: 'UTF-8'), :status => 200)
      reddit.get_data(article).should eq({:events=>[], :event_count=>0, :events_url=>"http://www.reddit.com/search?q=\"#{CGI.escape(article.doi_escaped)}\"", :event_metrics=>{:pdf=>nil, :html=>nil, :shares=>nil, :groups=>nil, :comments=>0, :likes=>0, :citations=>nil, :total=>0}})
      stub.should have_been_requested
    end

    it "should report if there are events and event_count returned by the Reddit API" do
      article = FactoryGirl.build(:article, :doi => "10.1371/journal.pone.0008776")
      stub = stub_request(:get, reddit.get_query_url(article)).to_return(:headers => { "Content-Type" => "application/json" }, :body => File.read(fixture_path + 'reddit.json', encoding: 'UTF-8'), :status => 200)
      response = reddit.get_data(article)
      response[:events].length.should eq(3)
      response[:event_count].should eq(1171)
      response[:event_metrics][:likes].should eq(1013)
      response[:event_metrics][:comments].should eq(158)
      response[:events_url].should eq("http://www.reddit.com/search?q=\"#{CGI.escape(article.doi_escaped)}\"")
      event = response[:events].first
      event[:event_url].should_not be_nil
      event[:event_url].should eq(event[:event]['url'])
      stub.should have_been_requested
    end

    it "should catch errors with the Reddit API" do
      article = FactoryGirl.build(:article, :doi => "10.1371/journal.pone.0000001")
      stub = stub_request(:get, reddit.get_query_url(article)).to_return(:status => [408])
      reddit.get_data(article, options = { :source_id => reddit.id }).should be_nil
      stub.should have_been_requested
      Alert.count.should == 1
      alert = Alert.first
      alert.class_name.should eq("Net::HTTPRequestTimeOut")
      alert.status.should == 408
      alert.source_id.should == reddit.id
    end
  end
end
