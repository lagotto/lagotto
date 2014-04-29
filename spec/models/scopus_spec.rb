# encoding: UTF-8

require 'spec_helper'

describe Scopus do
  subject { FactoryGirl.create(:scopus) }

  let(:article) { FactoryGirl.build(:article, :doi => "10.1371/journal.pmed.0030442") }

  context "get_data" do
    it "should report that there are no events if the DOI is missing" do
      article = FactoryGirl.build(:article, :doi => "")
      subject.get_data(article).should eq(events: [], event_count: nil)
    end

    it "should report if there are no events and event_count returned by the Scopus API" do
      article = FactoryGirl.build(:article, :doi => "10.1371/journal.pone.000001")
      body = File.read(fixture_path + 'scopus_nil.json')
      stub = stub_request(:get, subject.get_query_url(article)).with(:headers => { 'Accept'=>'application/json', 'User-Agent'=>"Article-Level Metrics #{Rails.application.config.version} - http://#{CONFIG[:hostname]}", 'X-ELS-APIKEY' => subject.api_key, 'X-ELS-INSTTOKEN' => subject.insttoken }).to_return(:headers => { "Content-Type" => "application/json" }, :body => body, :status => 200)
      response = subject.get_data(article)
      response.should eq(JSON.parse(body))
      stub.should have_been_requested
    end

    it "should report if there are events and event_count returned by the Scopus API" do
      body = File.read(fixture_path + 'scopus.json')
      events = JSON.parse(body)["search-results"]["entry"][0]
      stub = stub_request(:get, subject.get_query_url(article)).with(:headers => { 'Accept'=>'application/json', 'User-Agent'=>"Article-Level Metrics #{Rails.application.config.version} - http://#{CONFIG[:hostname]}", 'X-ELS-APIKEY' => subject.api_key, 'X-ELS-INSTTOKEN' => subject.insttoken }).to_return(:headers => { "Content-Type" => "application/json" }, :body => body, :status => 200)
      response = subject.get_data(article)
      response.should eq(JSON.parse(body))
      stub.should have_been_requested
    end

    it "should catch errors with the Scopus API" do
      stub = stub_request(:get, subject.get_query_url(article)).to_return(:status => [408])
      subject.get_data(article, options = { :source_id => subject.id }).should be_nil
      stub.should have_been_requested
      Alert.count.should == 1
      alert = Alert.first
      alert.class_name.should eq("Net::HTTPRequestTimeOut")
      alert.status.should == 408
      alert.source_id.should == subject.id
    end

    context "parse_data" do
      it "should report if there are no events and event_count returned by the Scopus API" do
        body = File.read(fixture_path + 'scopus_nil.json')
        result = JSON.parse(body)
        article = FactoryGirl.build(:article, :doi => "10.1371/journal.pone.000001")
        response = subject.parse_data(result, article)
        response.should eq(events: [], event_count: 0, event_metrics: { pdf: nil, html: nil, shares: nil, groups: nil, comments: nil, likes: nil, citations: 0, total: 0 })
      end

      it "should report if there are events and event_count returned by the Scopus API" do
        body = File.read(fixture_path + 'scopus.json')
        result = JSON.parse(body)
        events = JSON.parse(body)["search-results"]["entry"][0]
        response = subject.parse_data(result, article)
        response.should eq(events: events, event_count: 1814, events_url: "http://www.scopus.com/inward/citedby.url?partnerID=HzOxMe3b&scp=33845338724", event_metrics: { pdf: nil, html: nil, shares: nil, groups: nil, comments: nil, likes: nil, citations: 1814, total: 1814 })
      end
    end
  end
end
