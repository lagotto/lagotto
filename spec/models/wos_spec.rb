require 'spec_helper'

describe Wos do
  let(:wos) { FactoryGirl.create(:wos) }
  
  it "should report that there are no events if the doi is missing" do
    article_without_doi = FactoryGirl.build(:article, :doi => "")
    wos.get_data(article_without_doi).should eq({ :events => [], :event_count => nil })
  end
    
  context "use the Wos API" do
    let(:article) { FactoryGirl.build(:article, :doi => "10.1371/journal.pone.0043007") }
   
    it "should catch errors with the Wos API" do
      stub = stub_request(:post, wos.get_query_url(article)).with(:body => /.*/).to_return(:status => [408, "Request Timeout"])
      wos.get_data(article).should eq({ :events => [], :event_count => nil })
      stub.should have_been_requested
      ErrorMessage.count.should == 1
      error_message = ErrorMessage.first
      error_message.class_name.should eq("Net::HTTPRequestTimeOut")
      error_message.message.should include("Request Timeout")
      error_message.status.should == 408
      error_message.source_id.should == wos.id
    end
  end
end