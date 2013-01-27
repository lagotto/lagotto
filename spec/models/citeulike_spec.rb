require 'spec_helper'

describe Citeulike do
  let(:citeulike) { FactoryGirl.create(:citeulike) }
  
  it "should report that there are no events if the doi is missing" do
    article_without_doi = FactoryGirl.build(:article, :doi => "")
    citeulike.get_data(article_without_doi).should eq({ :events => [], :event_count => nil })
  end
  
  context "use the CiteULike API" do  
    it "should report if there are no events and event_count returned by the CiteULike API" do
      article_without_events = FactoryGirl.build(:article, :doi => "10.1371/journal.pone.0044294")
      body = File.read(fixture_path + 'citeulike_nil.xml')
      stub = stub_request(:get, citeulike.get_query_url(article_without_events)).to_return(:body => body, :status => 404)
      citeulike.get_data(article_without_events).should eq({ :events => [], :events_url => citeulike.get_events_url(article_without_events), :event_count => 0 })
      stub.should have_been_requested
    end
    
    it "should report if there are events and event_count returned by the CiteULike API" do
      article = FactoryGirl.build(:article, :doi => "10.1371/journal.pone.0008776")
      body = File.read(fixture_path + 'citeulike.xml')
      stub = stub_request(:get, citeulike.get_query_url(article)).to_return(:body => body, :status => 200)
      response = citeulike.get_data(article)
      response[:events].length.should eq(25)
      response[:events_url].should eq(citeulike.get_events_url(article))
      response[:event_count].should eq(25)
      response[:attachment][:data].should eq("<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n" + body)
      event = response[:events].first
      event[:event_url].should eq(event[:event]['link']['url'])
      stub.should have_been_requested
    end
  
    it "should catch errors with the CiteULike API" do
      article = FactoryGirl.build(:article, :doi => "10.1371/journal.pone.0000001")
      stub = stub_request(:get, citeulike.get_query_url(article)).to_return(:status => [408, "Request Timeout"])
      citeulike.get_data(article).should be_nil
      stub.should have_been_requested
      ErrorMessage.count.should == 1
      error_message = ErrorMessage.first
      error_message.class_name.should eq("Net::HTTPRequestTimeOut")
      error_message.message.should include("Request Timeout")
      error_message.status.should == 408
      error_message.source_id.should == citeulike.id
    end
  end
end