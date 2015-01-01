require 'rails_helper'

describe Wos, type: :model, vcr: true do
  subject { FactoryGirl.create(:wos) }

  let(:work) { FactoryGirl.build(:work, :doi => "10.1371/journal.pone.0043007") }

  it "should generate a proper XMl request" do
    work = FactoryGirl.build(:work, :doi => "10.1371/journal.pone.0043007")
    request = File.read(fixture_path + 'wos_request.xml')
    expect(subject.get_xml_request(work)).to eq(request)
  end

  context "get_data" do
    it "should report that there are no events if the doi is missing" do
      work_without_doi = FactoryGirl.build(:work, :doi => nil)
      expect(subject.get_data(work_without_doi)).to eq({})
    end

    it "should report if there are no events and event_count returned by the Wos API" do
      body = File.read(fixture_path + 'wos_nil.xml')
      stub = stub_request(:post, subject.get_query_url(work)).with(:body => /.*/, :headers => { "Accept" => "application/xml" }).to_return(:body => body)
      response = subject.get_data(work)
      expect(response).to eq(Hash.from_xml(body))
      expect(stub).to have_been_requested
    end

    it "should report if there are events and event_count returned by the Wos API" do
      body = File.read(fixture_path + 'wos.xml')
      stub = stub_request(:post, subject.get_query_url(work)).with(:body => /.*/, :headers => { "Accept" => "application/xml" }).to_return(:body => body)
      response = subject.get_data(work)
      expect(response).to eq(Hash.from_xml(body))
      expect(stub).to have_been_requested
    end

    it "should catch IP address errors with the Wos API" do
      body = File.read(fixture_path + 'wos_unauthorized.xml')
      stub = stub_request(:post, subject.get_query_url(work)).with(:body => /.*/, :headers => { "Accept" => "application/xml" }).to_return(:body => body)
      response = subject.get_data(work)
      expect(response).to eq(Hash.from_xml(body))
      expect(stub).to have_been_requested
    end

    it "should catch timeout errors with the Wos API" do
      stub = stub_request(:post, subject.get_query_url(work)).with(:body => /.*/, :headers => { "Accept" => "application/xml" }).to_return(:status => [408])
      response = subject.get_data(work, options = { :source_id => subject.id })
      expect(response).to eq(error: "the server responded with status 408 for https://ws.isiknowledge.com:80/cps/xrpc", status: 408)
      expect(stub).to have_been_requested
      expect(Alert.count).to eq(1)
      alert = Alert.first
      expect(alert.class_name).to eq("Net::HTTPRequestTimeOut")
      expect(alert.status).to eq(408)
      expect(alert.source_id).to eq(subject.id)
    end
  end

  context "parse_data" do
    it "should report that there are no events if the doi is missing" do
      work = FactoryGirl.build(:work, :doi => nil)
      result = {}
      result.extend Hashie::Extensions::DeepFetch
      response = subject.parse_data(result, work)
      expect(response).to eq(:events=>{}, :events_by_day=>[], :events_by_month=>[], :events_url=>nil, :event_count=>0, :event_metrics=>{:pdf=>nil, :html=>nil, :shares=>nil, :groups=>nil, :comments=>nil, :likes=>nil, :citations=>0, :total=>0})
    end

    it "should report if there are no events and event_count returned by the Wos API" do
      body = File.read(fixture_path + 'wos_nil_alt.xml')
      result = Hash.from_xml(body)
      result.extend Hashie::Extensions::DeepFetch
      response = subject.parse_data(result, work)
      expect(response).to eq(:events => {}, :events_by_day=>[], :events_by_month=>[], :event_count => 0, :events_url => nil, event_metrics: { pdf: nil, html: nil, shares: nil, groups: nil, comments: nil, likes: nil, citations: 0, total: 0 })
    end

    it "should report if there are events and event_count returned by the Wos API" do
      body = File.read(fixture_path + 'wos.xml')
      result = Hash.from_xml(body)
      result.extend Hashie::Extensions::DeepFetch
      response = subject.parse_data(result, work)
      expect(response[:event_count]).to eq(1005)
      expect(response[:events_url]).to include("http://gateway.webofknowledge.com/gateway/Gateway.cgi")
    end

    it "should catch IP address errors with the Wos API" do
      body = File.read(fixture_path + 'wos_unauthorized.xml')
      result = Hash.from_xml(body)
      result.extend Hashie::Extensions::DeepFetch
      response = subject.parse_data(result, work)
      expect(response).to eq(error: "Web of Science error Server.authentication: 'No matches returned for IP Address' for work #{work.doi}")
      expect(Alert.count).to eq(1)
      alert = Alert.first
      expect(alert.class_name).to eq("Net::HTTPUnauthorized")
      expect(alert.message).to include("Web of Science error Server.authentication")
      expect(alert.status).to eq(401)
      expect(alert.source_id).to eq(subject.id)
    end

    it "should catch timeout errors with the Wos API" do
      work = FactoryGirl.create(:work, :doi => "10.2307/683422")
      result = { error: "the server responded with status 408 for https://ws.isiknowledge.com:80/cps/xrpc" }
      response = subject.parse_data(result, work)
      expect(response).to eq(result)
    end
  end
end
