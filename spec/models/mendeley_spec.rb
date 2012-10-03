require 'spec_helper'

describe Mendeley do
  
  before(:each) do
    @mendeley = FactoryGirl.create(:mendeley)
  end
  
  it "should report that there are no events if the doi, pmid and mendeley uuid are missing" do
    article_without_ids = FactoryGirl.build(:article, :doi => "", :pub_med => "")
    @mendeley.get_data(article_without_ids).should eq({ :events => [], :event_count => 0 })
  end
  
  context "use the Mendeley API" do
    it "should report if there are no events and event_count returned by the Mendeley API" do
      article_without_events = FactoryGirl.build(:article, :doi => "10.1371/journal.pone.0044294")
      stub = stub_request(:get, @mendeley.get_query_url(CGI.escape(CGI.escape(article_without_events.doi)), "doi")).to_return(:body => File.read(fixture_path + 'mendeley_nil.json'), :status => 200)
      stub_pubmed = stub_request(:get, @mendeley.get_query_url(article_without_events.pub_med, "pmid")).to_return(:body => File.read(fixture_path + 'mendeley_nil.json'), :status => 200)
      stub_related = stub_request(:get, @mendeley.get_related_url("46cb51a0-6d08-11df-afb8-0026b95d30b2")).to_return(:body => File.read(fixture_path + 'mendeley_related.json'), :status => 200)
      @mendeley.get_data(article_without_events).should eq({ :events => [], :event_count => 0 })
      stub.should have_been_requested
      stub_pubmed.should have_been_requested
    end
    
    it "should report if there are events and event_count returned by the Mendeley API" do
      @article = FactoryGirl.build(:article, :doi => "10.1371/journal.pone.0008776")
      stub = stub_request(:get, @mendeley.get_query_url(CGI.escape(CGI.escape(@article.doi)), "doi")).to_return(:body => File.read(fixture_path + 'mendeley.json'), :status => 200)
      stub_related = stub_request(:get, @mendeley.get_related_url("46cb51a0-6d08-11df-afb8-0026b95d30b2")).to_return(:body => File.read(fixture_path + 'mendeley_related.json'), :status => 200)
      response = @mendeley.get_data(@article)
      response[:event_count].should eq(4)
      stub.should have_been_requested
    end
    
    it "should catch errors with the Mendeley API" do
      @article = FactoryGirl.build(:article, :doi => "10.1371/journal.pone.0000001")
      stub = stub_request(:get, @mendeley.get_query_url(CGI.escape(CGI.escape(@article.doi)), "doi")).to_return(:status => 408)
      lambda { @mendeley.get_data(@article) }.should raise_error(Net::HTTPServerException)
      stub.should have_been_requested
    end
  end
end