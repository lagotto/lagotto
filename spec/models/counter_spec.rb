require 'spec_helper'

describe Counter do
  let(:counter) { FactoryGirl.create(:counter) }
  
  it "should report that there are no events if the doi is missing" do
    article_without_doi = FactoryGirl.build(:article, :doi => "")
    counter.get_data(article_without_doi).should eq({ :events => [], :event_count => nil })
  end
  
  context "use the Counter API" do
    it "should report if there are no events and event_count returned by the Counter API" do
      article = FactoryGirl.build(:article, :doi => "10.1371/journal.pone.0044294")
      body = File.read(fixture_path + 'counter_nil.xml')
      stub = stub_request(:get, counter.get_query_url(article)).to_return(:body => body, :status => 404)
      counter.get_data(article).should eq({ :events => [], :event_count => 0, :events_url => counter.get_query_url(article), :event_metrics => { :pdf=>0, :html=>0, :shares=>nil, :groups=>nil, :comments=>nil, :likes=>nil, :citations=>nil, :total=>0 }, :attachment => nil })
      stub.should have_been_requested
    end
    
    it "should report if there are events and event_count returned by the Counter API" do
      article = FactoryGirl.build(:article, :doi => "10.1371/journal.pone.0008776")
      body = File.read(fixture_path + 'counter.xml')
      stub = stub_request(:get, counter.get_query_url(article)).to_return(:body => body, :status => 200)
      response = counter.get_data(article)
      response[:events].length.should eq(37)
      response[:events_url].should eq(counter.get_query_url(article))
      response[:event_count].should eq(3387)
      response[:attachment][:data].should eq(body)
      response[:event_metrics].should eq({ :pdf=>447, :html=>2919, :shares=>nil, :groups=>nil, :comments=>nil, :likes=>nil, :citations=>nil, :total=>3387 })
      stub.should have_been_requested
    end
    
    it "should catch errors with the Counter API" do
      article = FactoryGirl.build(:article, :doi => "10.1371/journal.pone.0000001")
      stub = stub_request(:get, counter.get_query_url(article)).to_return(:status => [408, "Request Timeout"])
      counter.get_data(article).should be_nil
      stub.should have_been_requested
      ErrorMessage.count.should == 1
      error_message = ErrorMessage.first
      error_message.class_name.should eq("Net::HTTPRequestTimeOut")
      error_message.message.should include("Request Timeout")
      error_message.status.should == 408
      error_message.source_id.should == counter.id
    end
  end
end