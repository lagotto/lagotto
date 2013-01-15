require 'spec_helper'

describe Wikipedia do
  
  let(:wikipedia) { FactoryGirl.create(:wikipedia) }
  
  it "should report that there are no events if the doi is missing" do
    article_without_doi = FactoryGirl.build(:article, :doi => "")
    wikipedia.get_data(article_without_doi).should eq({ :events => [], :event_count => 0 })
  end
  
  context "use the Wikipedia API" do
    it "should report if there are no events and event_count returned by the Wikipedia API" do
      article_without_events = FactoryGirl.build(:article, :doi => "10.1371/journal.pone.0044294")
      body = File.read(fixture_path + 'wikipedia_nil.json')
      stub = stub_request(:get, /.*wiki/).to_return(:body => body, :status => 200)
      wikipedia.get_data(article_without_events).should eq({ :events => [], :event_count => 0 })
    end
    
    it "should report if there are events and event_count returned by the Wikipedia API" do
      article = FactoryGirl.build(:article, :doi => "10.1371/journal.pcbi.1002445")
      body = File.read(fixture_path + 'wikipedia.json')
      stub = stub_request(:get, /.*wiki/).to_return(:body => body, :status => 200)
      response = wikipedia.get_data(article)
      response[:events].length.should eq(Wikipedia::LANGUAGES.length * 12)
      response[:event_count].should eq(Wikipedia::LANGUAGES.length * 12)
      event = response[:events].first
      event[:language].should eq("en")
    end
    
    it "should raise an error if search is temporarily disabled by the Wikipedia API" do
      article = FactoryGirl.build(:article, :doi => "10.1371/journal.pcbi.1002445")
      body = File.read(fixture_path + 'wikipedia_error.json')
      stub = stub_request(:get, /.*wiki/).to_return(:body => body, :status => 200)
      message = "Wikipedia text search is disabled"
      lambda { wikipedia.get_data(article) }.should raise_error(RuntimeError) { |error| error.message.should == message }
      stub.should have_been_requested
    end

    it "should catch errors with the Wikipedia API" do
      article = FactoryGirl.build(:article, :doi => "10.1371/journal.pone.0000001")
      stub = stub_request(:get, wikipedia.get_query_url(article)).to_return(:status => 408)
      lambda { wikipedia.get_data(article) }.should raise_error(Net::HTTPServerException)
      stub.should have_been_requested
    end
  end
end