require 'rails_helper'

describe EuropePmcData, type: :model, vcr: true do
  subject { FactoryGirl.create(:europe_pmc_data) }

  let(:work) { FactoryGirl.create(:work, :pmid => "14624247") }

  context "get_data" do
    it "should report that there are no events if the doi, pmid and pmcid are missing" do
      work = FactoryGirl.create(:work, doi: nil, pmid: nil, pmcid: nil)
      expect(subject.get_data(work)).to eq({})
    end

    it "should report if there are no events and event_count returned by the PMC Europe API" do
      work = FactoryGirl.create(:work, :pmid => "20098740")
      response = subject.get_data(work)
      expect(response["hitCount"]).to eq(0)
    end

    it "should report if there are events and event_count returned by the PMC Europe API" do
      response = subject.get_data(work)
      expect(response["hitCount"]).to eq(27737)
      cross_reference = response["dbCrossReferenceList"]["dbCrossReference"].first
      expect(cross_reference["dbCrossReferenceInfo"][0]["info1"]).to eq("CAAC03001572")
    end

    it "should catch errors with the PMC Europe API" do
      stub = stub_request(:get, subject.get_query_url(work)).to_return(:status => [408])
      response = subject.get_data(work, source_id: subject.id)
      expect(response).to eq(error: "the server responded with status 408 for http://www.ebi.ac.uk/europepmc/webservices/rest/MED/#{work.pmid}/databaseLinks//1/json", status: 408)
      expect(stub).to have_been_requested
      expect(Alert.count).to eq(1)
      alert = Alert.first
      expect(alert.class_name).to eq("Net::HTTPRequestTimeOut")
      expect(alert.status).to eq(408)
      expect(alert.source_id).to eq(subject.id)
    end
  end

  # context "get_data via accession_id" do
  #   it "should report that there are no events if the doi is missing" do
  #     subject.url = "http://www.ebi.ac.uk/europepmc/webservices/rest/search/query=ACCESSION_ID:%{doi}"
  #     work = FactoryGirl.create(:work, :doi => "")
  #     expect(subject.get_data(work)).to eq({})
  #   end

  #   it "should report if there are no events and event_count returned by the PMC Europe API" do
  #     subject.url = "http://www.ebi.ac.uk/europepmc/webservices/rest/search/query=ACCESSION_ID:%{doi}"
  #     work = FactoryGirl.create(:work, :pmid => "20098740")
  #     body = File.read(fixture_path + 'europe_pmc_data_nil.xml')
  #     stub = stub_request(:get, subject.get_query_url(work)).to_return(:body => body)
  #     response = subject.get_data(work)
  #     expect(response).to eq(Hash.from_xml(body))
  #     expect(stub).to have_been_requested
  #   end

  #   it "should report if there are events and event_count returned by the PMC Europe API" do
  #     subject.url = "http://www.ebi.ac.uk/europepmc/webservices/rest/search/query=ACCESSION_ID:%{doi}"
  #     body = File.read(fixture_path + 'europe_pmc_data.xml')
  #     stub = stub_request(:get, subject.get_query_url(work)).to_return(:body => body)
  #     response = subject.get_data(work)
  #     expect(response).to eq(Hash.from_xml(body))
  #     expect(stub).to have_been_requested
  #   end

  #   it "should catch errors with the PMC Europe API" do
  #     subject.url = "http://www.ebi.ac.uk/europepmc/webservices/rest/search/query=ACCESSION_ID:%{doi}"
  #     stub = stub_request(:get, subject.get_query_url(work)).to_return(:status => [408])
  #     response = subject.get_data(work, source_id: subject.id)
  #     expect(response).to eq(error: "the server responded with status 408 for http://www.ebi.ac.uk/europepmc/webservices/rest/search/query=ACCESSION_ID:#{work.doi}", status: 408)
  #     expect(stub).to have_been_requested
  #     expect(Alert.count).to eq(1)
  #     alert = Alert.first
  #     expect(alert.class_name).to eq("Net::HTTPRequestTimeOut")
  #     expect(alert.status).to eq(408)
  #     expect(alert.source_id).to eq(subject.id)
  #   end
  # end

  context "parse_data" do
    it "should report that there are no events if the pmid is missing" do
      work = FactoryGirl.create(:work, :pmid => "")
      result = {}
      result.extend Hashie::Extensions::DeepFetch
      expect(subject.parse_data(result, work)).to eq(works: [], events: { source: "pmc_europe_data", work: work.pid, total: 0, events_url: nil, extra: {} })
    end

    it "should report if there are no events and event_count returned by the PMC Europe API" do
      work = FactoryGirl.create(:work, :pmid => "20098740")
      body = File.read(fixture_path + 'europe_pmc_data_nil.json')
      result = JSON.parse(body)
      result.extend Hashie::Extensions::DeepFetch
      response = subject.parse_data(result, work)
      expect(response).to eq(works: [], events: { source: "pmc_europe_data", work: work.pid, total: 0, events_url: nil, extra: {} })
    end

    it "should report if there are events and event_count returned by the PMC Europe API" do
      body = File.read(fixture_path + 'europe_pmc_data.json')
      result = JSON.parse(body)
      result.extend Hashie::Extensions::DeepFetch
      response = subject.parse_data(result, work)
      expect(response[:events][:total]).to eq(21710)
      expect(response[:events][:events_url]).to eq("http://europepmc.org/abstract/MED/14624247#fragment-related-bioentities")
      expect(response[:events][:extra]).to eq("EMBL"=>10, "UNIPROT"=>21700)
    end

    it "should catch timeout errors with the PMC Europe API" do
      work = FactoryGirl.create(:work, :doi => "10.2307/683422")
      result = { error: "the server responded with status 408 for http://www.ebi.ac.uk/europepmc/webservices/rest/MED/#{work.pmid}/databaseLinks//1/json", status: 408 }
      response = subject.parse_data(result, work)
      expect(response).to eq(result)
    end
  end

  context "parse_data via accession_id" do
    it "should report that there are no events if the doi is missing" do
      work = FactoryGirl.create(:work, :doi => "", :pmid => "")
      result = {}
      result.extend Hashie::Extensions::DeepFetch
      expect(subject.parse_data(result, work)).to eq(works: [], events: { source: "pmc_europe_data", work: work.pid, total: 0, events_url: nil, extra: {} })
    end

    it "should report if there are no events and event_count returned by the PMC Europe API" do
      work = FactoryGirl.create(:work, :pmid => "")
      body = File.read(fixture_path + 'europe_pmc_data_nil.xml')
      result = Hash.from_xml(body)
      result.extend Hashie::Extensions::DeepFetch
      response = subject.parse_data(result, work)
      expect(response).to eq(works: [], events: { source: "pmc_europe_data", work: work.pid, total: 0, events_url: nil, extra: {} })
    end

    it "should report if there are events and event_count returned by the PMC Europe API" do
      work = FactoryGirl.create(:work, :pmid => "")
      body = File.read(fixture_path + 'europe_pmc_data.xml')
      result = Hash.from_xml(body)
      result.extend Hashie::Extensions::DeepFetch
      response = subject.parse_data(result, work)
      expect(response[:works].length).to eq(1)
      expect(response[:events][:total]).to eq(1)

      event = response[:works].first
      expect(event['author']).to eq([{"family"=>"Ha.", "given"=>"Piwowar"}])
      expect(event['title']).to eq("Who shares? Who doesn't? Factors associated with openly archiving raw research data.")
      expect(event['container-title']).to eq("PLoS One")
      expect(event['issued']).to eq("date-parts"=>[[2011]])
      expect(event['type']).to eq("article-journal")
      expect(event['URL']).to eq("http://europepmc.org/abstract/MED/21765886")
    end
  end
end
