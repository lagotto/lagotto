require 'spec_helper'

describe Counter do
  let(:counter) { FactoryGirl.create(:counter) }
  
  it "should report that there are no events if the doi is missing" do
    article_without_doi = FactoryGirl.build(:article, :doi => "")
    counter.get_data(article_without_doi).should eq({ :events => [], :event_count => nil })
  end
  
  context "use the Counter API" do  
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