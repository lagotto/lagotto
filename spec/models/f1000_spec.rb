require 'rails_helper'

describe F1000, type: :model, vcr: true do
  subject { FactoryGirl.create(:f1000) }

  context "get_data" do
    it "should report if there are no events returned by f1000" do
      body = File.read(fixture_path + 'f1000_nil.xml')
      stub = stub_request(:get, subject.get_query_url).to_return(:body => body, :status => [404])
      response = subject.get_data(nil)
      expect(response).to eq(error: { "ObjectList"=>nil }, status: 404)
      expect(stub).to have_been_requested
    end

    it "should report if there are events returned by f1000" do
      body = File.read(fixture_path + 'f1000.xml')
      stub = stub_request(:get, subject.get_query_url).to_return(:body => body)
      response = subject.get_data(nil)
      expect(response).to eq(Hash.from_xml(body))
      expect(stub).to have_been_requested
    end

    it "should catch not found errors with f1000" do
      stub = stub_request(:get, subject.get_query_url).to_return(status: [404], body: "")
      response = subject.get_data(nil, options = { :agent_id => subject.id })
      expect(response).to eq(error: nil, status: 404)
      expect(stub).to have_been_requested
      expect(Notification.count).to eq(0)
    end

    it "should catch timeout errors with f1000" do
      stub = stub_request(:get, subject.get_query_url).to_return(:status => [408])
      response = subject.get_data(nil, options = { :agent_id => subject.id })
      expect(response).to eq(error: "the server responded with status 408 for http://example.com/intermediate.xml", status: 408)
      expect(stub).to have_been_requested
      expect(Notification.count).to eq(1)
      notification = Notification.first
      expect(notification.class_name).to eq("Net::HTTPRequestTimeOut")
      expect(notification.status).to eq(408)
      expect(notification.agent_id).to eq(subject.id)
    end
  end

  context "parse_data" do
    it "should report if there are no events returned by f1000" do
      result = { error: nil, status: 404 }
      response = subject.parse_data(result, nil)
      expect(response).to eq(events: [])
    end

    it "should report if there are events returned by f1000" do
      body = File.read(fixture_path + 'f1000.xml')
      result = Hash.from_xml(body)
      response = subject.parse_data(result, nil)

      event = response[:events].first
      expect(event[:source_id]).to eq("f1000")
      expect(event[:work_id]).to eq("doi:10.1371/journal.pmed.0020059")
      expect(event[:total]).to eq(1)
      expect(event[:events_url]).to eq("http://f1000.com/prime/4085")
      expect(event[:extra]).to eq("doi"=>"10.1371/journal.pmed.0020059", "f1000_id"=>"4085", "url"=>"http://f1000.com/prime/4085", "score"=>1, "classifications"=>["technical_advance"])
    end
  end
end
