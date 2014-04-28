require 'spec_helper'

describe Figshare do
  subject { FactoryGirl.create(:figshare) }

  context "get_data" do
    it "should report that there are no events if the doi is missing" do
      article = FactoryGirl.build(:article, :doi => "")
      subject.get_data(article).should eq(events: [], event_count: nil)
    end

    it "should report that there are no events if the doi has the wrong prefix" do
      article = FactoryGirl.build(:article, :doi => "10.5194/acp-12-12021-2012")
      subject.get_data(article).should eq(events: [], event_count: nil)
    end

    it "should report if there are no events and event_count returned by the figshare API" do
      article = FactoryGirl.build(:article, :doi => "10.1371/journal.pone.0067729")
      body = File.read(fixture_path + 'figshare_nil.json')
      stub = stub_request(:get, subject.get_query_url(article)).to_return(:headers => { "Content-Type" => "application/json" }, :body => body, :status => 200)
      response = subject.get_data(article)
      response.should eq(JSON.parse(body))
      stub.should have_been_requested
    end

    it "should report if there are events and event_count returned by the figshare API" do
      article = FactoryGirl.build(:article, :doi => "10.1371/journal.pone.0067729")
      body = File.read(fixture_path + 'figshare.json')
      stub = stub_request(:get, subject.get_query_url(article)).to_return(:headers => { "Content-Type" => "application/json" }, :body => body, :status => 200)
      response = subject.get_data(article)
      response.should eq(JSON.parse(body))
      stub.should have_been_requested
    end

    it "should catch timeout errors with the figshare API" do
      article = FactoryGirl.build(:article, :doi => "10.1371/journal.pone.0067729")
      stub = stub_request(:get, subject.get_query_url(article)).to_return(:status => [408])
      subject.get_data(article, options = { :source_id => subject.id }).should be_nil
      stub.should have_been_requested
      Alert.count.should == 1
      alert = Alert.first
      alert.class_name.should eq("Net::HTTPRequestTimeOut")
      alert.status.should == 408
      alert.source_id.should == subject.id
    end
  end

  context "parse_data" do
    it "should report if there are no events and event_count returned by the figshare API" do
      body = File.read(fixture_path + 'figshare_nil.json')
      result = JSON.parse(body)
      response = subject.parse_data(result)
      response.should eq(events: [], event_count: nil)
    end

    it "should report if there are events and event_count returned by the figshare API" do
      body = File.read(fixture_path + 'figshare.json')
      result = JSON.parse(body)
      response = subject.parse_data(result)
      response[:event_count].should == 14
      response[:event_metrics].should eq(pdf: 1, html: 13, shares: nil, groups: nil, comments: nil, likes: 0, citations: nil, total: 14)
      events = response[:events]
      events["items"].should_not be_nil
    end
  end
end
