require 'rails_helper'

describe Copernicus, type: :model, vcr: true do
  subject { FactoryGirl.create(:copernicus) }

  let(:work) { FactoryGirl.create(:work, :doi => "10.5194/ms-2-175-2011") }

  context "get_data" do
    let(:auth) { ActionController::HttpAuthentication::Basic.encode_credentials(subject.username, subject.password) }

    it "should report that there are no events if the doi is missing" do
      work = FactoryGirl.create(:work, :doi => nil)
      expect(subject.get_data(work_id: work.id)).to eq({})
    end

    it "should report that there are no events if the doi has the wrong prefix" do
      work = FactoryGirl.create(:work, :doi => "10.1371/journal.pmed.0020124")
      expect(subject.get_data(work_id: work.id)).to eq({})
    end

    it "should report if there are no events and event_count returned by the Copernicus API" do
      work = FactoryGirl.create(:work, :doi => "10.5194/acp-12-12021-2012")
      body = File.read(fixture_path + 'copernicus_nil.json')
      stub = stub_request(:get, "http://harvester.copernicus.org/api/v1/articleStatisticsDoi/doi:#{work.doi}").with(:headers => { :authorization => auth }).to_return(:body => body)
      response = subject.get_data(work_id: work.id)
      expect(response).to eq('data' => JSON.parse(body))
      expect(stub).to have_been_requested
    end

    it "should report if there are events and event_count returned by the Copernicus API" do
      body = File.read(fixture_path + 'copernicus.json')
      stub = stub_request(:get, "http://harvester.copernicus.org/api/v1/articleStatisticsDoi/doi:#{work.doi}").with(:headers => { :authorization => auth }).to_return(:body => body)
      response = subject.get_data(work_id: work.id)
      expect(response).to eq(JSON.parse(body))
      expect(stub).to have_been_requested
    end

    it "should catch authentication errors with the Copernicus API" do
      stub = stub_request(:get, "http://harvester.copernicus.org/api/v1/articleStatisticsDoi/doi:#{work.doi}").with(:headers => { :authorization => auth }).to_return(:headers => { "Content-Type" => "application/json" }, :body => File.read(fixture_path + 'copernicus_unauthorized.json'), :status => [401, "Unauthorized: You are not authorized to access this resource."])
      response = subject.get_data(work_id: work, agent_id: subject.id)
      expect(response).to eq(error: "the server responded with status 401 for http://harvester.copernicus.org/api/v1/articleStatisticsDoi/doi:#{work.doi}", status: 401)
      expect(stub).to have_been_requested
      expect(Notification.count).to eq(1)
      notification = Notification.first
      expect(notification.class_name).to eq("Net::HTTPUnauthorized")
      expect(notification.status).to eq(401)
      expect(notification.agent_id).to eq(subject.id)
    end

    it "should catch timeout errors with the Copernicus API" do
      stub = stub_request(:get, "http://harvester.copernicus.org/api/v1/articleStatisticsDoi/doi:#{work.doi}").with(:headers => { :authorization => auth }).to_return(:status => [408])
      response = subject.get_data(work_id: work, agent_id: subject.id)
      expect(response).to eq(error: "the server responded with status 408 for http://harvester.copernicus.org/api/v1/articleStatisticsDoi/doi:#{work.doi}", :status=>408)
      expect(stub).to have_been_requested
      expect(Notification.count).to eq(1)
      notification = Notification.first
      expect(notification.class_name).to eq("Net::HTTPRequestTimeOut")
      expect(notification.status).to eq(408)
      expect(notification.agent_id).to eq(subject.id)
    end
  end

  context "parse_data" do
    it "should report if the doi is missing" do
      work = FactoryGirl.create(:work, :doi => nil)
      result = {}
      expect(subject.parse_data(result, work_id: work.id)).to eq([])
    end

    it "should report if there are no events and event_count returned by the Copernicus API" do
      body = File.read(fixture_path + 'copernicus_nil.json')
      result = { 'data' => JSON.parse(body) }
      expect(subject.parse_data(result, work_id: work.id)).to eq([])
    end

    it "should report if there are events and event_count returned by the Copernicus API" do
      body = File.read(fixture_path + 'copernicus.json')
      result = JSON.parse(body)
      response = subject.parse_data(result, work_id: work.id)

      expect(response.length).to eq(2)
      expect(response.first[:relation]).to eq("subj_id"=>"http://publications.copernicus.org",
                                              "obj_id"=>work.pid,
                                              "relation_type_id"=>"downloads",
                                              "total"=>10,
                                              "source_id"=>"copernicus")
      expect(response.last[:relation]).to eq("subj_id"=>"http://publications.copernicus.org",
                                             "obj_id"=>work.pid,
                                             "relation_type_id"=>"views",
                                             "total"=>72,
                                             "source_id"=>"copernicus")
    end
  end
end
