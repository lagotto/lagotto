require 'rails_helper'

describe F1000, type: :model, vcr: true do
  subject { FactoryGirl.create(:f1000) }

  context "get_data" do
    it "should report if there are no events returned by f1000" do
      body = File.read(fixture_path + 'f1000_nil.xml')
      stub = stub_request(:get, subject.get_query_url).to_return(:body => body, :status => [404])
      response = subject.get_data
      expect(response).to eq(error: { "ObjectList"=>nil }, status: 404)
      expect(stub).to have_been_requested
    end

    it "should report if there are events returned by f1000" do
      body = File.read(fixture_path + 'f1000.xml')
      stub = stub_request(:get, subject.get_query_url).to_return(:body => body)
      response = subject.get_data
      expect(response).to eq(Hash.from_xml(body))
      expect(stub).to have_been_requested
    end

    it "should catch not found errors with f1000" do
      stub = stub_request(:get, subject.get_query_url).to_return(status: [404], body: "")
      response = subject.get_data(source_id: subject.source_id)
      expect(response).to eq(error: "", status: 404)
      expect(stub).to have_been_requested
      expect(Notification.count).to eq(0)
    end

    it "should catch timeout errors with f1000" do
      stub = stub_request(:get, subject.get_query_url).to_return(:status => [408])
      response = subject.get_data(source_id: subject.source_id)
      expect(response).to eq(error: "the server responded with status 408 for http://example.com/intermediate.xml", status: 408)
      expect(stub).to have_been_requested
      expect(Notification.count).to eq(1)
      notification = Notification.first
      expect(notification.class_name).to eq("Net::HTTPRequestTimeOut")
      expect(notification.status).to eq(408)
    end
  end

  context "parse_data" do
    it "should report if there are no events returned by f1000" do
      result = { error: nil, status: 404 }
      response = subject.parse_data(result)
      expect(response).to eq([])
    end

    it "should report if there are events returned by f1000" do
      allow(Time.zone).to receive(:now).and_return(Time.mktime(2015, 4, 8))
      body = File.read(fixture_path + 'f1000.xml')
      result = Hash.from_xml(body)
      response = subject.parse_data(result)

      expect(response.length).to eq(10)
      expect(response[2][:relation]).to eq("subj_id"=>"http://f1000.com/prime/5020",
                                           "obj_id"=>"http://doi.org/10.1371/journal.pbio.0040009",
                                           "relation_type_id"=>"recommends",
                                           "total"=>6,
                                           "source_id"=>"f1000")

      expect(response[2][:subj]).to eq("pid"=>"http://f1000.com/prime/5020",
                                       "title"=>"F1000 Prime recommendation for DOI 10.1371/journal.pbio.0040009",
                                       "container-title"=>"F1000 Prime",
                                       "issued"=>"2015-04-08T00:00:00Z",
                                       "type"=>"entry",
                                       "tracked"=>false,
                                       "registration_agency_id"=>"f1000")
    end
  end
end
