require 'rails_helper'

describe Mendeley, :type => :model do

  subject { FactoryGirl.create(:mendeley) }

  context "CSV report" do
    before(:each) { allow(Time).to receive(:now).and_return(Time.mktime(2013, 9, 5)) }

    let(:url) { "#{ENV['COUCHDB_URL']}/_design/reports/_view/mendeley" }

    it "should format the CouchDB report as csv" do
      stub = stub_request(:get, url).to_return(:body => File.read(fixture_path + 'mendeley_report.json'))
      response = CSV.parse(subject.to_csv)
      expect(response.count).to eq(31)
      expect(response.first).to eq(["pid_type", "pid", "readers", "groups", "total"])
      expect(response.last).to eq(["doi", "10.5194/se-1-1-2010", "6", "0", "6"])
    end

    it "should report an error if the CouchDB design document can't be retrieved" do
      FactoryGirl.create(:fatal_error_report_with_admin_user)
      stub = stub_request(:get, url).to_return(:status => [404])
      expect(subject.to_csv).to be_nil
      expect(Alert.count).to eq(1)
      alert = Alert.first
      expect(alert.class_name).to eq("Faraday::ResourceNotFound")
      expect(alert.message).to eq("CouchDB report for Mendeley could not be retrieved.")
      expect(alert.status).to eq(404)
    end
  end

  context "lookup access token" do
    let(:auth) { ActionController::HttpAuthentication::Basic.encode_credentials(subject.client_id, subject.client_secret) }

    it "should make the right API call" do
      allow(Time).to receive(:now).and_return(Time.mktime(2013, 9, 5))
      subject.access_token = nil
      subject.expires_at = Time.now
      stub = stub_request(:post, subject.authentication_url).with(:body => "grant_type=client_credentials", :headers => { :authorization => auth })
             .to_return(:body => File.read(fixture_path + 'mendeley_auth.json'))
      expect(subject.get_access_token).not_to be false
      expect(stub).to have_been_requested
      expect(subject.access_token).to eq("MSwxMzk0OTg1MDcyMDk0LCwxOCwsLElEeF9XU256OWgzMDNlMmc4V0JaVkMyVnFtTQ")
      expect(subject.expires_at).to eq(Time.now + 3600.seconds)
    end

    it "should look up access token if blank" do
      subject.access_token = nil
      work = FactoryGirl.create(:work, :doi => "10.1371/journal.pone.0043007")
      stub_auth = stub_request(:post, subject.authentication_url).with(:headers => { :authorization => auth }, :body => "grant_type=client_credentials")
                  .to_return(:body => File.read(fixture_path + 'mendeley_auth.json'))
      stub_uuid = stub_request(:get, subject.get_lookup_url(work))
                  .to_return(:body => File.read(fixture_path + 'mendeley.json'))
      stub = stub_request(:get, subject.get_query_url(work)).to_return(:status => [408])

      response = subject.get_data(work, source_id: subject.id)
      expect(response[:error]).not_to be_nil
      expect(stub_auth).to have_been_requested
      expect(stub_uuid).to have_been_requested.times(2)
      expect(stub).to have_been_requested
    end

    it "should look up access token if expired" do
      subject.expires_at = Time.zone.now
      work = FactoryGirl.create(:work, :doi => "10.1371/journal.pone.0043007")
      stub_auth = stub_request(:post, subject.authentication_url).with(:headers => { :authorization => auth }, :body => "grant_type=client_credentials")
                  .to_return(:body => File.read(fixture_path + 'mendeley_auth.json'))
      stub_uuid = stub_request(:get, subject.get_lookup_url(work))
                  .to_return(:body => File.read(fixture_path + 'mendeley.json'))
      stub = stub_request(:get, subject.get_query_url(work)).to_return(:status => [408])

      response = subject.get_data(work, source_id: subject.id)
      expect(response[:error]).not_to be_nil
      expect(stub_auth).to have_been_requested
      expect(stub_uuid).to have_been_requested.times(2)
      expect(stub).to have_been_requested
    end

    it "should report that there are no events if access token can't be retrieved" do
      subject.access_token = nil
      work = FactoryGirl.create(:work, :doi => "10.1371/journal.pone.0043007")
      stub = stub_request(:post, subject.authentication_url).with(:headers => { :authorization => auth }, :body => "grant_type=client_credentials")
             .to_return(:body => "Credentials are required to access this resource.", :status => 401)
      expect(subject.get_data(work, options = { :source_id => subject.id })).to eq({})
      expect(stub).to have_been_requested
      expect(Alert.count).to eq(1)
      alert = Alert.first
      expect(alert.class_name).to eq("Net::HTTPUnauthorized")
      expect(alert.message).to eq("the server responded with status 401 for https://api-oauth2.mendeley.com/oauth/token")
      expect(alert.status).to eq(401)
    end
  end

  it "should report that there are no events if the doi, pmid, mendeley uuid and title are missing" do
    work_without_ids = FactoryGirl.build(:work, :doi => nil, :pmid => "", :mendeley_uuid => "", :title => "")
    expect(subject.get_data(work_without_ids)).to eq({})
  end

  context "use the Mendeley API for uuid lookup" do
    let(:work) { FactoryGirl.build(:work, :doi => "10.1371/journal.pone.0008776", :mendeley_uuid => "") }

    it "should return the Mendeley uuid by the Mendeley API" do
      stub = stub_request(:get, subject.get_lookup_url(work)).to_return(:body => File.read(fixture_path + 'mendeley.json'))
      expect(subject.get_mendeley_uuid(work)).to eq("46cb51a0-6d08-11df-afb8-0026b95d30b2")
      expect(stub).to have_been_requested
    end

    it "should return the Mendeley uuid by searching the Mendeley API" do
      work = FactoryGirl.build(:work, :doi => "10.1371/journal.pone.0000001", :mendeley_uuid => "")
      stub = stub_request(:get, subject.get_lookup_url(work)).to_return(:body => File.read(fixture_path + 'mendeley_nil.json'))
      stub_doi = stub_request(:get, subject.get_lookup_url(work, "doi")).to_return(:body => File.read(fixture_path + 'mendeley_nil.json'))
      stub_title = stub_request(:get, subject.get_lookup_url(work, "title")).to_return(:body => File.read(fixture_path + 'mendeley_search.json'))
      expect(subject.get_mendeley_uuid(work)).to eq("1779af10-6d0c-11df-a2b2-0026b95e3eb7")
      expect(stub).to have_been_requested
      expect(stub_doi).to have_been_requested
      expect(stub_title).to have_been_requested
    end

    it "should return nil for the Mendeley uuid if the Mendeley API returns malformed response" do
      stub = stub_request(:get, subject.get_lookup_url(work)).to_return(:body => File.read(fixture_path + 'mendeley_nil.json'))
      stub_doi = stub_request(:get, subject.get_lookup_url(work, "doi")).to_return(:body => File.read(fixture_path + 'mendeley_nil.json'))
      stub_title = stub_request(:get, subject.get_lookup_url(work, "title")).to_return(:body => File.read(fixture_path + 'mendeley_search.json'))
      expect(subject.get_mendeley_uuid(work)).to be_nil
      expect(stub).to have_been_requested
      expect(stub_doi).to have_been_requested
      expect(stub_title).to have_been_requested
      expect(Alert.count).to eq(0)
    end

    it "should return nil for the Mendeley uuid if the Mendeley API returns incomplete response" do
      stub = stub_request(:get, subject.get_lookup_url(work)).to_return(:body => File.read(fixture_path + 'mendeley_incomplete.json'))
      stub_doi = stub_request(:get, subject.get_lookup_url(work, "doi")).to_return(:body => File.read(fixture_path + 'mendeley_incomplete.json'))
      stub_title = stub_request(:get, subject.get_lookup_url(work, "title")).to_return(:body => File.read(fixture_path + 'mendeley_search.json'))
      expect(subject.get_mendeley_uuid(work)).to be_nil
      expect(stub).to have_been_requested
      expect(stub_doi).to have_been_requested
      expect(stub_title).to have_been_requested
      expect(Alert.count).to eq(0)
    end
  end

  context "get_data for metrics" do
    it "should report if there are events and event_count returned by the Mendeley API" do
      work = FactoryGirl.build(:work, :doi => "10.1371/journal.pone.0008776", :mendeley_uuid => "46cb51a0-6d08-11df-afb8-0026b95d30b2")
      body = File.read(fixture_path + 'mendeley.json')
      stub_uuid = stub_request(:get, subject.get_lookup_url(work)).to_return(:body => File.read(fixture_path + 'mendeley.json'))
      stub = stub_request(:get, subject.get_query_url(work)).to_return(:body => body)
      response = subject.get_data(work)
      expect(response).to eq(JSON.parse(body))
      expect(stub).to have_been_requested
    end

    it "should report no events and event_count if the Mendeley API returns incomplete response" do
      work = FactoryGirl.build(:work, :doi => "10.1371/journal.pone.0044294")
      body = File.read(fixture_path + 'mendeley_incomplete.json')
      stub_uuid = stub_request(:get, subject.get_lookup_url(work)).to_return(:body => File.read(fixture_path + 'mendeley.json'))
      stub = stub_request(:get, subject.get_query_url(work)).to_return(:body => body)
      response = subject.get_data(work)
      expect(response).to eq(JSON.parse(body))
      expect(stub).to have_been_requested
      expect(Alert.count).to eq(0)
    end

    it "should report no events and event_count if the Mendeley API returns malformed response" do
      work = FactoryGirl.build(:work, :doi => "10.1371/journal.pone.0044294")
      body = File.read(fixture_path + 'mendeley_nil.json')
      stub_uuid = stub_request(:get, subject.get_lookup_url(work)).to_return(:body => File.read(fixture_path + 'mendeley.json'))
      stub = stub_request(:get, subject.get_query_url(work)).to_return(:body => body, :status => 404)
      response = subject.get_data(work)
      expect(response).to eq(error: JSON.parse(body), status: 404)
      expect(Alert.count).to eq(0)
    end

    it "should report no events and event_count if the Mendeley API returns not found error" do
      work = FactoryGirl.build(:work)
      body = File.read(fixture_path + 'mendeley_error.json')
      stub_uuid = stub_request(:get, subject.get_lookup_url(work)).to_return(:body => File.read(fixture_path + 'mendeley.json'))
      stub = stub_request(:get, subject.get_query_url(work)).to_return(:body => body, :status => 404)
      response = subject.get_data(work)
      expect(response).to eq(error: JSON.parse(body)['error'], status: 404)
      expect(stub).to have_been_requested
      expect(Alert.count).to eq(0)
    end

    it "should filter out the mendeley_authors attribute" do
      work = FactoryGirl.build(:work, :doi => "10.1371/journal.pbio.0020002", :mendeley_uuid => "83e9b290-6d01-11df-936c-0026b95e484c")
      body = File.read(fixture_path + 'mendeley_authors_tag.json')
      stub_uuid = stub_request(:get, subject.get_lookup_url(work)).to_return(:body => File.read(fixture_path + 'mendeley_authors_tag.json'))
      stub = stub_request(:get, subject.get_query_url(work)).to_return(:body => body)
      response = subject.get_data(work)
      expect(response).to eq(JSON.parse(body))
      expect(stub).to have_been_requested
    end

    it "should catch timeout errors with the Mendeley API" do
      work = FactoryGirl.build(:work, :doi => "10.1371/journal.pone.0000001")
      stub_uuid = stub_request(:get, subject.get_lookup_url(work)).to_return(:body => File.read(fixture_path + 'mendeley.json'))
      stub = stub_request(:get, subject.get_query_url(work)).to_return(:status => [408])
      response = subject.get_data(work, source_id: subject.id)
      expect(response).to eq(error: "the server responded with status 408 for https://api-oauth2.mendeley.com/oapi/documents/details/#{work.mendeley_uuid}", :status=>408)
      expect(stub).to have_been_requested
      expect(Alert.count).to eq(1)
      alert = Alert.first
      expect(alert.class_name).to eq("Net::HTTPRequestTimeOut")
      expect(alert.status).to eq(408)
      expect(alert.source_id).to eq(subject.id)
    end
  end

  context "parse_data for metrics" do
    let(:work) { FactoryGirl.create(:work, :doi => "10.1371/journal.pone.0008776", :mendeley_uuid => "46cb51a0-6d08-11df-afb8-0026b95d30b2") }
    let(:null_response) { { :events=>{}, :events_by_day=>[], :events_by_month=>[], :events_url=>nil, :event_count=>0, :event_metrics=>{:pdf=>nil, :html=>nil, :shares=>0, :groups=>0, :comments=>nil, :likes=>nil, :citations=>nil, :total=>0 } } }

    it "should report if the doi, pmid, mendeley uuid and title are missing" do
      result = {}
      result.extend Hashie::Extensions::DeepFetch
      expect(subject.parse_data(result, work)).to eq(null_response)
    end

    it "should report if there are events and event_count returned by the Mendeley API" do
      body = File.read(fixture_path + 'mendeley.json')
      result = JSON.parse(body)
      result.extend Hashie::Extensions::DeepFetch
      response = subject.parse_data(result, work)
      expect(response[:events]).not_to be_nil
      expect(response[:events_url]).not_to be_nil
      expect(response[:event_count]).to eq(4)
    end

    it "should report no events and event_count if the Mendeley API returns incomplete response" do
      body = File.read(fixture_path + 'mendeley_incomplete.json')
      result = JSON.parse(body)
      result.extend Hashie::Extensions::DeepFetch
      expect(subject.parse_data(result, work)).to eq(null_response)
      expect(Alert.count).to eq(0)
    end

    it "should report no events and event_count if the Mendeley API returns malformed response" do
      body = File.read(fixture_path + 'mendeley_nil.json')
      result = { 'data' => body }
      result.extend Hashie::Extensions::DeepFetch
      expect(subject.parse_data(result, work)).to eq(null_response)
      expect(Alert.count).to eq(0)
    end

    it "should report no events and event_count if the Mendeley API returns not found error" do
      body = File.read(fixture_path + 'mendeley_error.json')
      result = { error: JSON.parse(body) }
      result.extend Hashie::Extensions::DeepFetch
      expect(subject.parse_data(result, work)).to eq(null_response)
      expect(Alert.count).to eq(0)
    end

    it "should catch timeout errors with the Mendeley API" do
      work = FactoryGirl.create(:work, :doi => "10.1371/journal.pone.0000001")
      result = { error: "the server responded with status 408 for https://api-oauth2.mendeley.com/oapi/documents/details/#{work.mendeley_uuid}", status: 408 }
      result.extend Hashie::Extensions::DeepFetch
      response = subject.parse_data(result, work)
      expect(response).to eq(result)
    end
  end
end
