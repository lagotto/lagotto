require 'rails_helper'

describe Scopus, type: :model do
  subject { FactoryGirl.create(:scopus) }

  let(:work) { FactoryGirl.create(:work, pid: "http://doi.org/10.1371/journal.pmed.0030442", doi: "10.1371/journal.pmed.0030442", scp: nil) }

  context "get_data" do
    it "should report that there are no events if the DOI is missing" do
      work = FactoryGirl.create(:work, :doi => "")
      expect(subject.get_data(work_id: work.id)).to eq({})
    end

    it "should report if there are no events and event_count returned by the Scopus API" do
      work = FactoryGirl.create(:work, :doi => "10.1371/journal.pone.000001")
      body = File.read(fixture_path + 'scopus_nil.json')
      stub = stub_request(:get, subject.get_query_url(work_id: work.id)).with(:headers => { 'Accept'=>'application/json', 'User-Agent'=>"Lagotto - http://#{ENV['SERVERNAME']}", 'X-ELS-APIKEY' => subject.api_key, 'X-ELS-INSTTOKEN' => subject.insttoken }).to_return(:headers => { "Content-Type" => "application/json" }, :body => body, :status => 200)
      response = subject.get_data(work_id: work.id)
      expect(response).to eq(JSON.parse(body))
      expect(stub).to have_been_requested
    end

    it "should report if there are events and event_count returned by the Scopus API" do
      body = File.read(fixture_path + 'scopus.json')
      events = JSON.parse(body)["search-results"]["entry"][0]
      stub = stub_request(:get, subject.get_query_url(work_id: work.id)).with(:headers => { 'Accept'=>'application/json', 'User-Agent'=>"Lagotto - http://#{ENV['SERVERNAME']}", 'X-ELS-APIKEY' => subject.api_key, 'X-ELS-INSTTOKEN' => subject.insttoken }).to_return(:headers => { "Content-Type" => "application/json" }, :body => body, :status => 200)
      response = subject.get_data(work_id: work.id)
      expect(response).to eq(JSON.parse(body))
      expect(stub).to have_been_requested
    end

    it "should catch timeout errors with the Scopus API" do
      stub = stub_request(:get, subject.get_query_url(work_id: work.id)).to_return(:status => [408])
      response = subject.get_data(work_id: work.id, source_id: subject.source_id)
      expect(response).to eq(error: "the server responded with status 408 for https://api.elsevier.com/content/search/index:SCOPUS?query=DOI(#{work.doi_escaped})", :status=>408)
      expect(stub).to have_been_requested
      expect(Notification.count).to eq(1)
      notification = Notification.first
      expect(notification.class_name).to eq("Net::HTTPRequestTimeOut")
      expect(notification.status).to eq(408)
    end

    context "parse_data" do
      it "should report if the doi is missing" do
        result = {}
        result.extend Hashie::Extensions::DeepFetch
        expect(subject.parse_data(result, work_id: work.id)).to eq([])
      end

      it "should report if there are no events and event_count returned by the Scopus API" do
        body = File.read(fixture_path + 'scopus_nil.json')
        result = JSON.parse(body)
        result.extend Hashie::Extensions::DeepFetch
        work = FactoryGirl.create(:work, :doi => "10.1371/journal.pone.000001")
        response = subject.parse_data(result, work_id: work.id)
        expect(response).to eq([])
      end

      it "should report if there are events and event_count returned by the Scopus API" do
        body = File.read(fixture_path + 'scopus.json')
        result = JSON.parse(body)
        result.extend Hashie::Extensions::DeepFetch
        events = JSON.parse(body)["search-results"]["entry"][0]
        response = subject.parse_data(result, work_id: work.id)

        expect(response.length).to eq(1)
        expect(response.first[:relation]).to eq("subj_id"=>"http://www.scopus.com",
                                                "obj_id"=>"http://doi.org/10.1371/journal.pmed.0030442",
                                                "relation_type_id"=>"cites",
                                                "total"=>1814,
                                                "provenance_url"=>"http://www.scopus.com/inward/citedby.url?partnerID=HzOxMe3b&scp=33845338724",
                                                "source_id"=>"scopus")
        expect(response.first[:subj]).to eq("pid"=>"http://www.scopus.com",
                                            "URL"=>"http://www.scopus.com",
                                            "title"=>"Scopus",
                                            "issued"=>"2012-05-15T16:40:23Z")
        expect(work.scp).to eq("000237966900006")
      end

      it "should catch timeout errors with the Scopus API" do
        work = FactoryGirl.create(:work, :doi => "10.2307/683422")
        result = { error: "the server responded with status 408 for https://api.elsevier.com/content/search/index:SCOPUS?query=DOI(#{work.doi_escaped})", status: 408 }
        response = subject.parse_data(result, work_id: work.id)
        expect(response).to eq([result])
      end
    end
  end
end
