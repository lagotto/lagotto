require 'rails_helper'

describe Wos, type: :model, vcr: true do
  subject { FactoryGirl.create(:wos) }

  let(:work) { FactoryGirl.create(:work, doi: "10.1371/journal.pone.0043007", wos: nil) }

  it "should generate a proper XML request" do
    work = FactoryGirl.create(:work, :doi => "10.1371/journal.pone.0043007")
    request = File.read(fixture_path + 'wos_request.xml')
    expect(subject.get_xml_request(work)).to eq(request)
  end

  context "get_data" do
    it "should report that there are no events if the doi is missing" do
      work = FactoryGirl.create(:work, :doi => nil)
      expect(subject.get_data(work)).to eq({})
    end

    it "should report if there are no events returned by the Wos API" do
      body = File.read(fixture_path + 'wos_nil.xml')
      stub = stub_request(:post, subject.get_query_url(work)).with(:body => /.*/, :headers => { "Accept" => "application/xml" }).to_return(:body => body)
      response = subject.get_data(work)
      expect(response).to eq(Hash.from_xml(body))
      expect(stub).to have_been_requested
    end

    it "should report if there are events returned by the Wos API" do
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
      response = subject.get_data(work, options = { :agent_id => subject.id })
      expect(response).to eq(error: "the server responded with status 408 for https://ws.isiknowledge.com:80/cps/xrpc", status: 408)
      expect(stub).to have_been_requested
      expect(Notification.count).to eq(1)
      notification = Notification.first
      expect(notification.class_name).to eq("Net::HTTPRequestTimeOut")
      expect(notification.status).to eq(408)
      expect(notification.agent_id).to eq(subject.id)
    end
  end

  context "parse_data" do
    it "should report that there are no events if the doi is missing" do
      work = FactoryGirl.create(:work, :doi => nil)
      result = {}
      result.extend Hashie::Extensions::DeepFetch
      response = subject.parse_data(result, work)
      expect(response).to eq(events: [{ source_id: "wos", work_id: work.pid, total: 0, events_url: nil }])
    end

    it "should report if there are no events returned by the Wos API" do
      body = File.read(fixture_path + 'wos_nil.xml')
      result = Hash.from_xml(body)
      result.extend Hashie::Extensions::DeepFetch
      response = subject.parse_data(result, work)
      expect(response).to eq(events: [{ source_id: "wos", work_id: work.pid, total: 0, events_url: nil }])
    end

    it "should report if there are no events returned by the Wos API with alt response" do
      body = File.read(fixture_path + 'wos_nil_alt.xml')
      result = Hash.from_xml(body)
      result.extend Hashie::Extensions::DeepFetch
      response = subject.parse_data(result, work)
      expect(response).to eq(events: [{ source_id: "wos", work_id: work.pid, total: 0, events_url: nil }])
    end

    it "should report if there are events returned by the Wos API" do
      body = File.read(fixture_path + 'wos.xml')
      result = Hash.from_xml(body)
      result.extend Hashie::Extensions::DeepFetch
      response = subject.parse_data(result, work)

      event = response[:events].first
      expect(event[:source_id]).to eq("wos")
      expect(event[:work_id]).to eq(work.pid)
      expect(event[:total]).to eq(1005)
      expect(event[:events_url]).to include("http://gateway.webofknowledge.com/gateway/Gateway.cgi")
      expect(work.wos).to eq("000237966900006")
    end

    it "should catch IP address errors with the Wos API" do
      body = File.read(fixture_path + 'wos_unauthorized.xml')
      result = Hash.from_xml(body)
      result.extend Hashie::Extensions::DeepFetch
      response = subject.parse_data(result, work)
      expect(response).to eq(error: "Web of Science error Server.authentication: 'No matches returned for IP Address' for work #{work.doi}")
      expect(Notification.count).to eq(1)
      notification = Notification.first
      expect(notification.class_name).to eq("Net::HTTPUnauthorized")
      expect(notification.message).to include("Web of Science error Server.authentication")
      expect(notification.status).to eq(401)
      expect(notification.source_id).to eq(subject.id)
    end

    it "should catch timeout errors with the Wos API" do
      work = FactoryGirl.create(:work, :doi => "10.2307/683422")
      result = { error: "the server responded with status 408 for https://ws.isiknowledge.com:80/cps/xrpc" }
      response = subject.parse_data(result, work)
      expect(response).to eq(result)
    end
  end
end
