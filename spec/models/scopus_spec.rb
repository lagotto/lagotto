# encoding: UTF-8

require 'spec_helper'

describe Scopus do
  subject { FactoryGirl.create(:scopus) }

  let(:article) { FactoryGirl.build(:article, :doi => "10.1371/journal.pmed.0030442") }

  context "get_data" do
    it "should report that there are no events if the DOI is missing" do
      article = FactoryGirl.build(:article, :doi => "")
      subject.get_data(article).should eq({})
    end

    it "should report if there are no events and event_count returned by the Scopus API" do
      article = FactoryGirl.build(:article, :doi => "10.1371/journal.pone.000001")
      body = File.read(fixture_path + 'scopus_nil.json')
      stub = stub_request(:get, subject.get_query_url(article)).with(:headers => { 'Accept'=>'application/json', 'User-Agent'=>"Article-Level Metrics #{Rails.application.config.version} - http://#{CONFIG[:server_name]}", 'X-ELS-APIKEY' => subject.api_key, 'X-ELS-INSTTOKEN' => subject.insttoken }).to_return(:headers => { "Content-Type" => "application/json" }, :body => body, :status => 200)
      response = subject.get_data(article)
      response.should eq(JSON.parse(body))
      stub.should have_been_requested
    end

    it "should report if there are events and event_count returned by the Scopus API" do
      body = File.read(fixture_path + 'scopus.json')
      events = JSON.parse(body)["search-results"]["entry"][0]
      stub = stub_request(:get, subject.get_query_url(article)).with(:headers => { 'Accept'=>'application/json', 'User-Agent'=>"Article-Level Metrics #{Rails.application.config.version} - http://#{CONFIG[:server_name]}", 'X-ELS-APIKEY' => subject.api_key, 'X-ELS-INSTTOKEN' => subject.insttoken }).to_return(:headers => { "Content-Type" => "application/json" }, :body => body, :status => 200)
      response = subject.get_data(article)
      response.should eq(JSON.parse(body))
      stub.should have_been_requested
    end

    it "should catch timeout errors with the Scopus API" do
      stub = stub_request(:get, subject.get_query_url(article)).to_return(:status => [408])
      response = subject.get_data(article, options = { :source_id => subject.id })
      response.should eq(error: "the server responded with status 408 for https://api.elsevier.com/content/search/index:SCOPUS?query=DOI(#{article.doi_escaped})", :status=>408)
      stub.should have_been_requested
      Alert.count.should == 1
      alert = Alert.first
      alert.class_name.should eq("Net::HTTPRequestTimeOut")
      alert.status.should == 408
      alert.source_id.should == subject.id
    end

    context "parse_data" do
      it "should report if the doi is missing" do
        result = {}
        result.extend Hashie::Extensions::DeepFetch
        subject.parse_data(result, article).should eq(events: {}, :events_by_day=>[], :events_by_month=>[], events_url: nil, event_count: 0, event_metrics: { pdf: nil, html: nil, shares: nil, groups: nil, comments: nil, likes: nil, citations: 0, total: 0 })
      end

      it "should report if there are no events and event_count returned by the Scopus API" do
        body = File.read(fixture_path + 'scopus_nil.json')
        result = JSON.parse(body)
        result.extend Hashie::Extensions::DeepFetch
        article = FactoryGirl.build(:article, :doi => "10.1371/journal.pone.000001")
        response = subject.parse_data(result, article)
        response.should eq(:events=>{"@force-array"=>"true", "error"=>"Result set was empty"}, :events_by_day=>[], :events_by_month=>[], :events_url=>nil, :event_count=>0, :event_metrics=>{:pdf=>nil, :html=>nil, :shares=>nil, :groups=>nil, :comments=>nil, :likes=>nil, :citations=>0, :total=>0})
      end

      it "should report if there are events and event_count returned by the Scopus API" do
        body = File.read(fixture_path + 'scopus.json')
        result = JSON.parse(body)
        result.extend Hashie::Extensions::DeepFetch
        events = JSON.parse(body)["search-results"]["entry"][0]
        response = subject.parse_data(result, article)
        response.should eq(events: events, :events_by_day=>[], :events_by_month=>[], event_count: 1814, events_url: "http://www.scopus.com/inward/citedby.url?partnerID=HzOxMe3b&scp=33845338724", event_metrics: { pdf: nil, html: nil, shares: nil, groups: nil, comments: nil, likes: nil, citations: 1814, total: 1814 })
      end

      it "should catch timeout errors with the Scopus API" do
        article = FactoryGirl.create(:article, :doi => "10.2307/683422")
        result = { error: "the server responded with status 408 for https://api.elsevier.com/content/search/index:SCOPUS?query=DOI(#{article.doi_escaped})", status: 408 }
        response = subject.parse_data(result, article)
        response.should eq(result)
      end
    end
  end
end
