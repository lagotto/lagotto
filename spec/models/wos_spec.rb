require 'spec_helper'

describe Wos do
  subject { FactoryGirl.create(:wos) }

  let(:article) { FactoryGirl.build(:article, :doi => "10.1371/journal.pone.0043007") }

  it "should generate a proper XMl request" do
    article = FactoryGirl.build(:article, :doi => "10.1371/journal.pone.0043007")
    request = File.read(fixture_path + 'wos_request.xml')
    subject.get_xml_request(article).should eq(request)
  end

  context "get_data" do
    it "should report that there are no events if the doi is missing" do
      article_without_doi = FactoryGirl.build(:article, :doi => nil)
      subject.get_data(article_without_doi).should eq({})
    end

    it "should report if there are no events and event_count returned by the Wos API" do
      body = File.read(fixture_path + 'wos_nil.xml')
      stub = stub_request(:post, subject.get_query_url(article)).with(:body => /.*/, :headers => { "Accept" => "application/xml" }).to_return(:body => body)
      response = subject.get_data(article)
      response.should eq(Hash.from_xml(body))
      stub.should have_been_requested
    end

    it "should report if there are events and event_count returned by the Wos API" do
      body = File.read(fixture_path + 'wos.xml')
      stub = stub_request(:post, subject.get_query_url(article)).with(:body => /.*/, :headers => { "Accept" => "application/xml" }).to_return(:body => body)
      response = subject.get_data(article)
      response.should eq(Hash.from_xml(body))
      stub.should have_been_requested
    end

    it "should catch IP address errors with the Wos API" do
      body = File.read(fixture_path + 'wos_unauthorized.xml')
      stub = stub_request(:post, subject.get_query_url(article)).with(:body => /.*/, :headers => { "Accept" => "application/xml" }).to_return(:body => body)
      response = subject.get_data(article)
      response.should eq(Hash.from_xml(body))
      stub.should have_been_requested
    end

    it "should catch timeout errors with the Wos API" do
      stub = stub_request(:post, subject.get_query_url(article)).with(:body => /.*/, :headers => { "Accept" => "application/xml" }).to_return(:status => [408])
      response = subject.get_data(article, options = { :source_id => subject.id })
      response.should eq(error: "the server responded with status 408 for https://ws.isiknowledge.com:80/cps/xrpc")
      stub.should have_been_requested
      Alert.count.should == 1
      alert = Alert.first
      alert.class_name.should eq("Net::HTTPRequestTimeOut")
      alert.status.should == 408
      alert.source_id.should == subject.id
    end
  end

  context "parse_data" do
    it "should report that there are no events if the doi is missing" do
      article = FactoryGirl.build(:article, :doi => nil)
      result = {}
      result.extend Hashie::Extensions::DeepFetch
      response = subject.parse_data(result, article)
      response.should eq(:events=>{}, :events_by_day=>[], :events_by_month=>[], :events_url=>nil, :event_count=>0, :event_metrics=>{:pdf=>nil, :html=>nil, :shares=>nil, :groups=>nil, :comments=>nil, :likes=>nil, :citations=>0, :total=>0})
    end

    it "should report if there are no events and event_count returned by the Wos API" do
      body = File.read(fixture_path + 'wos_nil_alt.xml')
      result = Hash.from_xml(body)
      result.extend Hashie::Extensions::DeepFetch
      response = subject.parse_data(result, article)
      response.should eq(:events => {}, :events_by_day=>[], :events_by_month=>[], :event_count => 0, :events_url => nil, event_metrics: { pdf: nil, html: nil, shares: nil, groups: nil, comments: nil, likes: nil, citations: 0, total: 0 })
    end

    it "should report if there are events and event_count returned by the Wos API" do
      body = File.read(fixture_path + 'wos.xml')
      result = Hash.from_xml(body)
      result.extend Hashie::Extensions::DeepFetch
      response = subject.parse_data(result, article)
      response[:event_count].should eq(1005)
      response[:events_url].should include("http://gateway.webofknowledge.com/gateway/Gateway.cgi")
    end

    it "should catch IP address errors with the Wos API" do
      body = File.read(fixture_path + 'wos_unauthorized.xml')
      result = Hash.from_xml(body)
      result.extend Hashie::Extensions::DeepFetch
      response = subject.parse_data(result, article)
      response.should eq(error: "Web of Science error Server.authentication: 'No matches returned for IP Address' for article #{article.doi}")
      Alert.count.should == 1
      alert = Alert.first
      alert.class_name.should eq("Net::HTTPUnauthorized")
      alert.message.should include("Web of Science error Server.authentication")
      alert.status.should == 401
      alert.source_id.should == subject.id
    end

    it "should catch timeout errors with the Wos API" do
      article = FactoryGirl.create(:article, :doi => "10.2307/683422")
      result = { error: "the server responded with status 408 for https://ws.isiknowledge.com:80/cps/xrpc" }
      response = subject.parse_data(result, article)
      response.should eq(result)
    end
  end
end
