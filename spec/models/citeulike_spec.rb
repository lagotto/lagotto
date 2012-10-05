require 'spec_helper'

describe Citeulike do
  
  before(:each) do
    @citeulike = FactoryGirl.create(:citeulike)
    @article = FactoryGirl.build(:article, :doi => "10.1371/journal.pone.0000001")
  end
  
  it "should report that there are no events if the doi is missing" do
    article_without_doi = FactoryGirl.build(:article, :doi => "")
    @citeulike.get_data(article_without_doi).should eq({ :events => [], :event_count => 0 })
  end
  
  context "use the CiteULike API" do  
    it "should report if there are no events and event_count returned by the Mendeley API" do
      article_without_events = FactoryGirl.build(:article, :doi => "10.1371/journal.pone.0044294")
      stub = stub_request(:get, @citeulike.get_query_url(article_without_events)).to_return(:body => File.read(fixture_path + 'citeulike_nil.xml'), :status => 200)
      @citeulike.get_data(article_without_events)[:event_count].should eq(0)
      stub.should have_been_requested
    end
    
    it "should report if there are events and event_count returned by the Mendeley API" do
      @article = FactoryGirl.build(:article, :doi => "10.1371/journal.pone.0008776")
      stub = stub_request(:get, @citeulike.get_query_url(@article)).to_return(:body => File.read(fixture_path + 'citeulike.xml'), :status => 200)
      response = @citeulike.get_data(@article)
      response[:event_count].should eq(25)
      stub.should have_been_requested
    end
  
    it "should catch errors with the CiteULike API" do
      stub = stub_request(:get, @citeulike.get_query_url(@article)).to_return(:status => 408)
      lambda { @citeulike.get_data(@article) }.should raise_error(Net::HTTPServerException)
      stub.should have_been_requested
    end
  end

end