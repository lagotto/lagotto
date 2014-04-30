require 'spec_helper'

describe Wikipedia do

  subject { FactoryGirl.create(:wikipedia) }

  context "get_data" do
    it "should report that there are no events if the doi is missing" do
      article = FactoryGirl.build(:article, :doi => "")
      subject.get_data(article).should eq(events: [], event_count: nil)
    end

    it "should report if there are no events and event_count returned by the Wikipedia API" do
      article = FactoryGirl.build(:article, :doi => "10.1371/journal.pone.0044294")
      body = File.read(fixture_path + 'wikipedia_nil.json')
      stub = stub_request(:get, /en.wikipedia.org/).to_return(:body => body, :status => 200)
      response = subject.get_data(article)
      response.should eq("en"=>0)
      stub.should have_been_requested
    end

    it "should report if there are events and event_count returned by the Wikipedia API" do
      article = FactoryGirl.build(:article, :doi => "10.1371/journal.pcbi.1002445")
      body = File.read(fixture_path + 'wikipedia.json')
      stub = stub_request(:get, /en.wikipedia.org/).to_return(:headers => { "Content-Type" => "application/json" }, :body => body, :status => 200)
      response = subject.get_data(article)
      response.should eq("en"=>12)
      stub.should have_been_requested
    end

    it "should catch errors with the Wikipedia API" do
      article = FactoryGirl.build(:article, :doi => "10.1371/journal.pone.0000001")
      stub = stub_request(:get, /en.wikipedia.org/).to_return(:headers => { "Content-Type" => "application/json" }, :body => File.read(fixture_path + 'wikipedia_error.json'), :status => [408])
      response = subject.get_data(article, options = { :source_id => subject.id })
      p response
      response['error'].should_not be_nil
      stub.should have_been_requested
      Alert.count.should == 1
      alert = Alert.first
      alert.class_name.should eq("Net::HTTPRequestTimeOut")
      alert.status.should == 408
      alert.source_id.should == subject.id
    end
  end

  context "get_data from Wikimedia Commons" do
    subject { FactoryGirl.create(:wikipedia, languages: "en commons") }

    it "should report if there are events and event_count returned by the Wikimedia Commons API" do
      article = FactoryGirl.build(:article, :doi => "10.1371/journal.pone.0044271")
      body = File.read(fixture_path + 'wikipedia_commons.json')
      stub = stub_request(:get, /en.wikipedia.org/).to_return(:headers => { "Content-Type" => "application/json" }, :body => File.read(fixture_path + 'wikipedia.json'), :status => 200)
      stub_commons = stub_request(:get, /commons.wikimedia.org/).to_return(:headers => { "Content-Type" => "application/json" }, :body => body, :status => 200)
      response = subject.get_data(article)
      response.should eq("en"=>12, "commons"=>8)
      stub.should have_been_requested
    end

  end

  context "parse_data" do
    it "should report if there are no events and event_count returned by the Wikipedia API" do
      article = FactoryGirl.build(:article, :doi => "10.1371/journal.pone.0044294")
      result = { "en"=>0 }
      response = subject.parse_data(result, article)
      response[:event_count].should == 0
    end

    it "should report if there are events and event_count returned by the Wikipedia API" do
      article = FactoryGirl.build(:article, :doi => "10.1371/journal.pcbi.1002445")
      result = { "en"=>12 }
      response = subject.parse_data(result, article)
      response[:events].length.should eq(1 + 1)
      response[:event_count].should eq(1 * 12)
    end

    it "should report if there are events and event_count returned by the Wikimedia Commons API" do
      article = FactoryGirl.build(:article, :doi => "10.1371/journal.pone.0044271")
      result = { "en"=>12, "commons"=>8 }
      response = subject.parse_data(result, article)
      response[:events].length.should eq(1 + 1 + 1)
      response[:event_count].should eq(8 + 12)
    end
  end
end
