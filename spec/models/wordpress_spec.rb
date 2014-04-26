# encoding: UTF-8

require 'spec_helper'

describe Wordpress do
  subject { FactoryGirl.create(:wordpress) }

  it "should report that there are no events if the doi is missing" do
    article = FactoryGirl.build(:article, :doi => "")
    subject.parse_data(article).should eq(events: [], event_count: nil)
  end

  context "use the Wordpress API" do
    it "should report if there are no events and event_count returned by the Wordpress API" do
      article = FactoryGirl.build(:article, :doi => "10.1371/journal.pone.0044294")
      stub = stub_request(:get, subject.get_query_url(article)).to_return(:headers => { "Content-Type" => "application/json" }, :body => File.read(fixture_path + 'wordpress_nil.json', encoding: 'UTF-8'), :status => 200)
      subject.parse_data(article).should eq(events: [], event_count: 0)
      stub.should have_been_requested
    end

    it "should report if there are events and event_count returned by the Wordpress API" do
      article = FactoryGirl.build(:article, :doi => "10.1371/journal.pone.0008776")
      stub = stub_request(:get, subject.get_query_url(article)).to_return(:headers => { "Content-Type" => "application/json" }, :body => File.read(fixture_path + 'wordpress.json', encoding: 'UTF-8'), :status => 200)
      response = subject.parse_data(article)
      response[:events_url].should eq("http://en.search.wordpress.com/?q=\"#{article.doi}\"&t=post")
      event = response[:events].first
      event[:event_url].should_not be_nil
      event[:event_url].should eq(event[:event]['link'])
      stub.should have_been_requested
    end

    it "should catch errors with the Wordpress API" do
      article = FactoryGirl.build(:article, :doi => "10.1371/journal.pone.0000001")
      stub = stub_request(:get, subject.get_query_url(article)).to_return(:status => [408])
      subject.parse_data(article, options = { :source_id => subject.id }).should eq(events: [], event_count: 0)
      stub.should have_been_requested
      Alert.count.should == 1
      alert = Alert.first
      alert.class_name.should eq("Net::HTTPRequestTimeOut")
      alert.status.should == 408
      alert.source_id.should == subject.id
    end
  end
end
