require 'rails_helper'

describe EuropePmcData, type: :model, vcr: true do
  subject { FactoryGirl.create(:europe_pmc_data) }

  let(:work) { FactoryGirl.create(:work, pmid: "14624247", pmcid: "2808249") }

  context "get_data" do
    it "should report that there are no events if the doi, pmid and pmcid are missing" do
      work = FactoryGirl.create(:work, doi: nil, pmid: nil, pmcid: nil)
      expect(subject.get_data(work_id: work.id)).to eq({})
    end

    it "should report if there are no events and event_count returned by the PMC Europe API" do
      work = FactoryGirl.create(:work, doi: "10.1371/journal.pone.0008776", pmid: "20098740", pmcid: "2808249")
      response = subject.get_data(work_id: work.id)
      expect(response["hitCount"]).to eq(0)
    end

    it "should report if there are events and event_count returned by the PMC Europe API" do
      response = subject.get_data(work_id: work.id)
      expect(response["hitCount"]).to eq(22396)
      cross_reference = response["dbCrossReferenceList"]["dbCrossReference"].first
      expect(cross_reference["dbCrossReferenceInfo"][0]["info1"]).to eq("HE601321")
    end

    it "should catch errors with the PMC Europe API" do
      stub = stub_request(:get, subject.get_query_url(work_id: work.id)).to_return(:status => [408])
      response = subject.get_data(work_id: work, source_id: subject.source_id)
      expect(response).to eq(error: "the server responded with status 408 for http://www.ebi.ac.uk/europepmc/webservices/rest/MED/#{work.pmid}/databaseLinks//1/json", status: 408)
      expect(stub).to have_been_requested
      expect(Notification.count).to eq(1)
      notification = Notification.first
      expect(notification.class_name).to eq("Net::HTTPRequestTimeOut")
      expect(notification.status).to eq(408)
    end
  end

  context "parse_data" do
    it "should report that there are no events if the doi, pmid and pmcid are missing" do
      work = FactoryGirl.create(:work, doi: nil, pmid: nil, pmcid: nil)
      result = {}
      result.extend Hashie::Extensions::DeepFetch
      expect(subject.parse_data(result, work_id: work.id)).to eq([])
    end

    it "should report if there are no events and event_count returned by the PMC Europe API" do
      work = FactoryGirl.create(:work, :pmid => "20098740")
      body = File.read(fixture_path + 'europe_pmc_data_nil.json')
      result = JSON.parse(body)
      result.extend Hashie::Extensions::DeepFetch
      response = subject.parse_data(result, work_id: work.id)
      expect(response).to eq([])
    end

    it "should report if there are events and event_count returned by the PMC Europe API" do
      body = File.read(fixture_path + 'europe_pmc_data.json')
      result = JSON.parse(body)
      result.extend Hashie::Extensions::DeepFetch
      response = subject.parse_data(result, work_id: work.id)

      expect(response.length).to eq(1)
      expect(response.first[:relation]).to eq("subj_id"=>"https://europepmc.org",
                                              "obj_id"=>work.pid,
                                              "relation_type_id"=>"cites",
                                              "total"=>21710,
                                              "provenance_url"=>"http://europepmc.org/abstract/MED/14624247#fragment-related-bioentities",
                                              "source_id"=>"pmc_europe_data")

      expect(response.first[:subj]).to eq("pid"=>"https://europepmc.org",
                                          "URL"=>"https://europepmc.org",
                                          "title"=>"Europe PMC",
                                          "type"=>"webpage",
                                          "issued"=>"2012-05-15T16:40:23Z")
    end

    it "should catch timeout errors with the PMC Europe API" do
      work = FactoryGirl.create(:work, doi: "10.1371/journal.pone.0008776", pmid: "20098740", pmcid: "2808249")
      result = { error: "the server responded with status 408 for http://www.ebi.ac.uk/europepmc/webservices/rest/MED/#{work.pmid}/databaseLinks//1/json", status: 408 }
      response = subject.parse_data(result, work_id: work.id)
      expect(response).to eq([result])
    end
  end
end
