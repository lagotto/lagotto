require 'spec_helper'

describe Wos do
  let(:wos) { FactoryGirl.create(:wos) }
  
  it "should report that there are no events if the doi is missing" do
    article_without_doi = FactoryGirl.build(:article, :doi => "")
    wos.get_data(article_without_doi).should eq({ :events => [], :event_count => nil })
  end
    
  context "use the Wos API" do
    let(:article) { FactoryGirl.build(:article, :doi => "10.1371/journal.pone.0043007") }
    
    it "should report if there are no events and event_count returned by the Wos API" do
      stub = stub_request(:post, wos.get_query_url(article)).with(:body => /.*/, :headers => { "Content-Type" => "text/xml", "User-Agent" => "Article Level Metrics - http://test.example.org" }).to_return(:body => File.read(fixture_path + 'wos_nil.xml'), :status => 200)
      wos.get_data(article).should eq({ :events => 0, :event_count => 0, :events_url => nil })
      stub.should have_been_requested
    end
  
    it "should report if there are events and event_count returned by the Wos API" do
      body = "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<request xmlns=\"http://www.isinet.com/xrpc42\" src=\"app.id=Article Level Metrics,env.id=test,partner.email=mfenner@plos.org\">\n  <fn name=\"LinksAMR.retrieve\">\n    <list>\n      <map/>\n      <map>\n        <list name=\"WOS\">\n          <val>timesCited</val>\n          <val>ut</val>\n          <val>citingArticlesURL</val>\n        </list>\n      </map>\n      <map>\n        <map name=\"cite_id\">\n          <val name=\"doi\">10.1371/journal.pone.0043007</val>\n        </map>\n      </map>\n    </list>\n  </fn>\n</request>\n"
      stub = stub_request(:post, wos.get_query_url(article)).with(:body => body, :headers => { "Content-Type" => "text/xml", "User-Agent" => "Article Level Metrics - http://test.example.org" }).to_return(:body => File.read(fixture_path + 'wos.xml'), :status => 200)
      response = wos.get_data(article)
      response[:event_count].should eq(1005)
      response[:events_url].should include("http://gateway.webofknowledge.com/gateway/Gateway.cgi")
      response[:attachment][:data].should be_true
      stub.should have_been_requested
    end
    
    it "should catch IP address errors with the Wos API" do
      stub = stub_request(:post, wos.get_query_url(article)).with(:body => /.*/, :headers => { "Content-Type" => "text/xml", "User-Agent" => "Article Level Metrics - http://test.example.org" }).to_return(:body => File.read(fixture_path + 'wos_unauthorized.xml'), :status => 200)
      wos.get_data(article).should eq({ :events => [], :event_count => nil })
      stub.should have_been_requested
      ErrorMessage.count.should == 1
      error_message = ErrorMessage.first
      error_message.class_name.should eq("Net::HTTPUnauthorized")
      error_message.message.should include("Web of Science error Server.authentication")
      error_message.status.should == 401
      error_message.source_id.should == wos.id
    end
   
    it "should catch errors with the Wos API" do
      stub = stub_request(:post, wos.get_query_url(article)).with(:body => /.*/, :headers => { "Content-Type" => "text/xml", "User-Agent" => "Article Level Metrics - http://test.example.org" }).to_return(:status => [408, "Request Timeout"])
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