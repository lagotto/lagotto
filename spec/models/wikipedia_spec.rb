require 'spec_helper'

describe Wikipedia do

  let(:wikipedia) { FactoryGirl.create(:wikipedia) }

  it "should report that there are no events if the doi is missing" do
    article_without_doi = FactoryGirl.build(:article, :doi => "")
    wikipedia.get_data(article_without_doi).should eq({ :events => [], :event_count => nil })
  end

  context "use the Wikipedia API" do
    it "should report if there are no events and event_count returned by the Wikipedia API" do
      article_without_events = FactoryGirl.build(:article, :doi => "10.1371/journal.pone.0044294")
      stub = stub_request(:get, /.*wiki/).to_return(:body => File.read(fixture_path + 'wikipedia_nil.json'), :status => 200)
      response = wikipedia.get_data(article_without_events)
      response[:event_count].should == 0
    end

    it "should report if there are events and event_count returned by the Wikipedia API" do
      article = FactoryGirl.build(:article, :doi => "10.1371/journal.pcbi.1002445")
      stub = stub_request(:get, /.*wiki/).to_return(:headers => { "Content-Type" => "application/json" }, :body => File.read(fixture_path + 'wikipedia.json'), :status => 200)
      response = wikipedia.get_data(article)
      response[:events].length.should eq(Wikipedia::LANGUAGES.length + 1)
      response[:event_count].should eq(Wikipedia::LANGUAGES.length * 12)
    end

    it "should catch errors with the Wikipedia API" do
      article = FactoryGirl.build(:article, :doi => "10.1371/journal.pone.0000001")
      stub = stub_request(:get, /.*wiki/).to_return(:headers => { "Content-Type" => "application/json" }, :body => File.read(fixture_path + 'wikipedia_error.json'), :status => [408])
      wikipedia.get_data(article, options = { :source_id => wikipedia.id }).should be_nil
      stub.should have_been_requested
      Alert.count.should == 1
      alert = Alert.first
      alert.class_name.should eq("Net::HTTPRequestTimeOut")
      alert.status.should == 408
      alert.source_id.should == wikipedia.id
    end
  end
end
