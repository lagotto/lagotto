require 'rails_helper'

describe Mendeley, :type => :model, vcr: true do
  subject { FactoryGirl.create(:mendeley) }

  context "lookup access token" do
    let(:auth) { ActionController::HttpAuthentication::Basic.encode_credentials(subject.client_id, subject.client_secret) }

    it "should make the right API call" do
      allow(Time.zone).to receive(:now).and_return(Time.mktime(2013, 9, 5))
      subject.access_token = nil
      subject.expires_at = Time.now
      stub = stub_request(:post, subject.authentication_url).with(:body => "grant_type=client_credentials&scope=all", :headers => { :authorization => auth })
             .to_return(:body => File.read(fixture_path + 'mendeley_auth.json'))
      expect(subject.get_access_token).not_to be false
      expect(stub).to have_been_requested
      expect(subject.access_token).to eq("MSwxMzk0OTg1MDcyMDk0LCwxOCwsLElEeF9XU256OWgzMDNlMmc4V0JaVkMyVnFtTQ")
      expect(subject.expires_at).to eq(Time.zone.now + 3600.seconds)
    end

    it "should look up access token if blank" do
      subject.access_token = nil
      work = FactoryGirl.create(:work, :doi => "10.1371/journal.pone.0043007")
      stub_auth = stub_request(:post, subject.authentication_url).with(:headers => { :authorization => auth }, :body => "grant_type=client_credentials&scope=all")
                  .to_return(:body => File.read(fixture_path + 'mendeley_auth.json'))
      stub = stub_request(:get, subject.get_query_url(work_id: work)).to_return(:status => [408])

      response = subject.get_data(work_id: work.id, source_id: subject.source_id)
      expect(response[:error]).not_to be_nil
      expect(stub_auth).to have_been_requested
      expect(stub).to have_been_requested
    end

    it "should look up access token if expired" do
      subject.expires_at = Time.zone.now
      work = FactoryGirl.create(:work, :doi => "10.1371/journal.pone.0043007")
      stub_auth = stub_request(:post, subject.authentication_url).with(:headers => { :authorization => auth }, :body => "grant_type=client_credentials&scope=all")
                  .to_return(:body => File.read(fixture_path + 'mendeley_auth.json'))
      stub = stub_request(:get, subject.get_query_url(work_id: work)).to_return(:status => [408])

      response = subject.get_data(work_id: work.id, source_id: subject.source_id)
      expect(response[:error]).not_to be_nil
      expect(stub_auth).to have_been_requested
      expect(stub).to have_been_requested
    end

    it "should report that there are no events if access token can't be retrieved" do
      subject.access_token = nil
      work = FactoryGirl.create(:work, :doi => "10.1371/journal.pone.0043007")
      stub = stub_request(:post, subject.authentication_url).with(:headers => { :authorization => auth }, :body => "grant_type=client_credentials&scope=all")
             .to_return(:body => "Credentials are required to access this resource.", :status => 401)
      expect { subject.get_data(work_id: work.id, source_id: subject.source_id) }.to raise_error(ArgumentError, "No Mendeley access token.")
      expect(stub).to have_been_requested

      expect(Notification.count).to eq(1)
      notification = Notification.first
      expect(notification.class_name).to eq("Net::HTTPUnauthorized")
      expect(notification.message).to eq("the server responded with status 401 for https://api.mendeley.com/oauth/token")
      expect(notification.status).to eq(401)
    end
  end

  it "should report that there are no events if the doi, pmid, and scp are missing" do
    work = FactoryGirl.create(:work, doi: nil, pmid: nil, scp: nil)
    expect(subject.get_data(work_id: work.id)).to eq({})
  end

  context "get_data" do
    it "should report if there are events returned by the Mendeley API" do
      work = FactoryGirl.create(:work, :doi => "10.1371/journal.pone.0008776", :mendeley_uuid => "46cb51a0-6d08-11df-afb8-0026b95d30b2")
      response = subject.get_data(work_id: work.id)
      data = response["data"].first
      expect(data["reader_count"]).to eq(46)
      expect(data["group_count"]).to eq(1)
      expect(data["link"]).to eq("http://www.mendeley.com/research/island-rule-deepsea-gastropods-reexamining-evidence")
    end

    it "should report no events if the Mendeley API returns malformed response" do
      work = FactoryGirl.create(:work, :doi => "10.1371/journal.pone.0044294")
      body = File.read(fixture_path + 'mendeley_nil.json')
      stub = stub_request(:get, subject.get_query_url(work_id: work.id)).to_return(:body => body, :status => 404)
      response = subject.get_data(work_id: work.id)
      expect(response).to eq(error: JSON.parse(body), status: 404)
      expect(Notification.count).to eq(0)
    end

    it "should report no events if the Mendeley API returns not found error" do
      work = FactoryGirl.create(:work)
      response = subject.get_data(work_id: work.id)
      expect(response).to eq("data"=>[])
      expect(Notification.count).to eq(0)
    end

    it "should catch timeout errors with the Mendeley API" do
      work = FactoryGirl.create(:work, :doi => "10.1371/journal.pone.0000001")
      stub = stub_request(:get, subject.get_query_url(work_id: work.id)).to_return(:status => [408])
      response = subject.get_data(work_id: work.id, source_id: subject.source_id)
      expect(response).to eq(error: "the server responded with status 408 for https://api.mendeley.com/catalog?doi=#{work.doi}&view=stats", :status=>408)
      expect(stub).to have_been_requested
      expect(Notification.count).to eq(1)
      notification = Notification.first
      expect(notification.class_name).to eq("Net::HTTPRequestTimeOut")
      expect(notification.status).to eq(408)
    end
  end

  context "parse_data" do
    let(:work) { FactoryGirl.create(:work, pid: "http://doi.org/10.1371/journal.pone.0008776", doi: "10.1371/journal.pone.0008776", mendeley_uuid: "46cb51a0-6d08-11df-afb8-0026b95d30b2") }

    it "should report if the doi, pmid, mendeley uuid and title are missing" do
      result = {}
      result.extend Hashie::Extensions::DeepFetch
      expect(subject.parse_data(result, work_id: work)).to eq([])
    end

    it "should report if there are events returned by the Mendeley API" do
      body = File.read(fixture_path + 'mendeley.json')
      result = { "data" => JSON.parse(body) }
      result.extend Hashie::Extensions::DeepFetch
      response = subject.parse_data(result, work_id: work)

      expect(response.length).to eq(1)
      expect(response[0][:relation]).to eq("subj_id"=>"http://www.mendeley.com/research/island-rule-deepsea-gastropods-reexamining-evidence",
                                           "obj_id"=>work.pid,
                                           "relation_type_id"=>"bookmarks",
                                           "total"=>34,
                                           "source_id"=>"mendeley")
    end

    it "should report no events if the Mendeley API returns incomplete response" do
      body = File.read(fixture_path + 'mendeley_incomplete.json')
      result = JSON.parse(body)
      result.extend Hashie::Extensions::DeepFetch
      expect(subject.parse_data(result, work_id: work)).to eq([])
      expect(Notification.count).to eq(0)
    end

    it "should report no events if the Mendeley API returns malformed response" do
      body = File.read(fixture_path + 'mendeley_nil.json')
      result = { 'data' => JSON.parse(body) }
      result.extend Hashie::Extensions::DeepFetch
      expect(subject.parse_data(result, work_id: work)).to eq([])
      expect(Notification.count).to eq(0)
    end

    it "should report no events if the Mendeley API returns not found error" do
      body = File.read(fixture_path + 'mendeley_error.json')
      result = { error: JSON.parse(body) }
      result.extend Hashie::Extensions::DeepFetch
      expect(subject.parse_data(result, work_id: work)).to eq([])
      expect(Notification.count).to eq(0)
    end

    it "should catch timeout errors with the Mendeley API" do
      work = FactoryGirl.create(:work, :doi => "10.1371/journal.pone.0000001")
      result = { error: "the server responded with status 408 for https://api-oauth2.mendeley.com/oapi/documents/details/#{work.mendeley_uuid}", status: 408 }
      response = subject.parse_data(result, work_id: work)
      expect(response).to eq([result])
    end
  end
end
