require 'spec_helper'

describe CrossRef do
  before(:each) do
    @cross_ref = FactoryGirl.create(:cross_ref)
    @article = FactoryGirl.create(:article, :doi => "10.1371/journal.pone.0000001")
  end
  
  it "should report that there are no events if the doi is missing" do
    article_without_doi = FactoryGirl.build(:article, :doi => "")
    @cross_ref.get_data(article_without_doi).should eq({ :events => [], :event_count => 0 })
  end
    
  context "use the CrossRef API" do
    it "should report if there are no events and event_count returned by the CrossRef API" do
      article_without_events = FactoryGirl.build(:article, :doi => "10.1371/journal.pone.0043007")
      stub = stub_request(:get, @cross_ref.get_query_url(article_without_events)).to_return(:body => File.read(fixture_path + 'cross_ref_nil.xml'), :status => 200)
      @cross_ref.get_data(article_without_events).should eq({ :events => [], :event_count => 0 })
      stub.should have_been_requested
    end
  
    it "should report if there are events and event_count returned by the CrossRef API" do
      stub = stub_request(:get, @cross_ref.get_query_url(@article)).to_return(:body => File.read(fixture_path + 'cross_ref.xml'), :status => 200)
      response = @cross_ref.get_data(@article)
      response[:events].length.should eq(31)
      response[:event_count].should eq(31)
      stub.should have_been_requested
    end
   
    it "should catch errors with the CrossRef API" do
      stub = stub_request(:get, @cross_ref.get_query_url(@article)).to_return(:status => 408)
      lambda { @cross_ref.get_data(@article) }.should raise_error(Net::HTTPServerException)
      stub.should have_been_requested
    end
  end
  
  context "use the CrossRef OpenURL API" do
    it "should report if there is an event_count of zero returned by the CrossRef OpenURL API" do
      @article = FactoryGirl.build(:article, :doi => "10.1007/s00248-010-9734-2")
      stub = stub_request(:get, @cross_ref.get_default_query_url(@article)).to_return(:body => File.read(fixture_path + 'cross_ref_openurl_nil.xml'), :status => 200)
      @cross_ref.get_data(@article).should eq({ :events => [], :event_count => 0 })
      stub.should have_been_requested
    end
  
    it "should report if there is an event_count greater than zero returned by the CrossRef OpenURL API" do
      @article = FactoryGirl.build(:article, :doi => "10.1007/s00248-010-9734-2")
      stub = stub_request(:get, @cross_ref.get_default_query_url(@article)).to_return(:body => File.read(fixture_path + 'cross_ref_openurl.xml'), :status => 200)
      response = @cross_ref.get_data(@article)
      response[:event_count].should eq(13)
      stub.should have_been_requested
    end
   
    it "should catch errors with the CrossRef OpenURL API" do
      @article = FactoryGirl.build(:article, :doi => "10.1007/s00248-010-9734-2")
      stub = stub_request(:get, @cross_ref.get_default_query_url(@article)).to_return(:status => 408)
      lambda { @cross_ref.get_data(@article) }.should raise_error(Net::HTTPServerException)
      stub.should have_been_requested
    end
  end
end
