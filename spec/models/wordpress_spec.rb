# encoding: UTF-8

require 'spec_helper'

describe Wordpress do
  subject { FactoryGirl.create(:wordpress) }

  context "get_data" do
    it "should report that there are no events if the doi is missing" do
      article = FactoryGirl.build(:article, :doi => "")
      subject.get_data(article).should eq(events: [], event_count: nil)
    end

    it "should report if there are no events and event_count returned by the Wordpress API" do
      article = FactoryGirl.build(:article, :doi => "10.1371/journal.pone.0044294")
      body = File.read(fixture_path + 'wordpress_nil.json', encoding: 'UTF-8')
      stub = stub_request(:get, subject.get_query_url(article)).to_return(:headers => { "Content-Type" => "application/json" }, :body => body, :status => 200)
      response = subject.get_data(article)
      response.should eq('error' => "unexpected token for JSON")
      stub.should have_been_requested
    end

    it "should report if there are events and event_count returned by the Wordpress API" do
      article = FactoryGirl.build(:article, :doi => "10.1371/journal.pone.0008776")
      body = File.read(fixture_path + 'wordpress.json', encoding: 'UTF-8')
      stub = stub_request(:get, subject.get_query_url(article)).to_return(:headers => { "Content-Type" => "application/json" }, :body => body, :status => 200)
      response = subject.get_data(article)
      response.should eq(JSON.parse(body))
      stub.should have_been_requested
    end

    it "should catch errors with the Wordpress API" do
      article = FactoryGirl.build(:article, :doi => "10.1371/journal.pone.0000001")
      stub = stub_request(:get, subject.get_query_url(article)).to_return(:status => [408])
      response = subject.get_data(article, options = { :source_id => subject.id })
      response['error'].should_not be_nil
      stub.should have_been_requested
      Alert.count.should == 1
      alert = Alert.first
      alert.class_name.should eq("Net::HTTPRequestTimeOut")
      alert.status.should == 408
      alert.source_id.should == subject.id
    end
  end

  context "parse_data" do
    it "should report if there are no events and event_count returned by the Wordpress API" do
      article = FactoryGirl.build(:article, :doi => "10.1371/journal.pone.0044294")
      result = { 'error' => "unexpected token for JSON" }
      response = subject.parse_data(result, article)
      response.should eq(:events=>[], :events_url=>"http://en.search.wordpress.com/?q=\"#{article.doi_escaped}\"&t=post", :event_count=>0, :event_metrics=>{:pdf=>nil, :html=>nil, :shares=>nil, :groups=>nil, :comments=>nil, :likes=>nil, :citations=>0, :total=>0})
    end

    it "should report if there are events and event_count returned by the Wordpress API" do
      article = FactoryGirl.build(:article, :doi => "10.1371/journal.pone.0008776")
      body = File.read(fixture_path + 'wordpress.json', encoding: 'UTF-8')
      result = JSON.parse(body, article: article)
      response = subject.parse_data(result, article)
      response[:events_url].should eq("http://en.search.wordpress.com/?q=\"#{article.doi_escaped}\"&t=post")
      event = response[:events].first
      event[:event_url].should_not be_nil
      event[:event_url].should eq(event[:event]['link'])
    end
  end
end
