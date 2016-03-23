require 'rails_helper'

describe EuropePmcFulltextData, type: :model, vcr: true do
  subject { FactoryGirl.create(:europe_pmc_fulltext_data) }

  let(:work) { FactoryGirl.create(:work, :pmid => "14624247") }

  context "get_data" do
    it "should report that there are no events if the doi is missing" do
      work = FactoryGirl.create(:work, :doi => "")
      expect(subject.get_data(work_id: work.id)).to eq({})
    end

    it "should report if there are no events and event_count returned by the PMC Europe API" do
      work = FactoryGirl.create(:work, :pmid => "20098740")
      body = File.read(fixture_path + 'europe_pmc_fulltext_data_nil.xml')
      stub = stub_request(:get, subject.get_query_url(work_id: work.id)).to_return(:body => body)
      response = subject.get_data(work_id: work.id)
      expect(response).to eq(Hash.from_xml(body))
      expect(stub).to have_been_requested
    end

    it "should report if there are events and event_count returned by the PMC Europe API" do
      body = File.read(fixture_path + 'europe_pmc_fulltext_data.xml')
      stub = stub_request(:get, subject.get_query_url(work_id: work.id)).to_return(:body => body)
      response = subject.get_data(work_id: work.id)
      expect(response).to eq(Hash.from_xml(body))
      expect(stub).to have_been_requested
    end

    it "should catch errors with the PMC Europe API" do
      stub = stub_request(:get, subject.get_query_url(work_id: work.id)).to_return(:status => [408])
      response = subject.get_data(work_id: work.id, source_id: subject.source_id)
      expect(response).to eq(error: "the server responded with status 408 for http://www.ebi.ac.uk/europepmc/webservices/rest/search/query=ACCESSION_ID:#{work.doi}", status: 408)
      expect(stub).to have_been_requested
      expect(Notification.count).to eq(1)
      notification = Notification.first
      expect(notification.class_name).to eq("Net::HTTPRequestTimeOut")
      expect(notification.status).to eq(408)
    end
  end

  context "parse_data" do
    it "should report that there are no events if the doi is missing" do
      work = FactoryGirl.create(:work, :doi => "", :pmid => "")
      result = {}
      result.extend Hashie::Extensions::DeepFetch
      expect(subject.parse_data(result, work_id: work.id)).to eq([])
    end

    it "should report if there are no events and event_count returned by the PMC Europe API" do
      work = FactoryGirl.create(:work, :pmid => "")
      body = File.read(fixture_path + 'europe_pmc_fulltext_data_nil.xml')
      result = Hash.from_xml(body)
      result.extend Hashie::Extensions::DeepFetch
      expect(subject.parse_data(result, work_id: work.id)).to eq([])
    end

    it "should report if there are events and event_count returned by the PMC Europe API" do
      work = FactoryGirl.create(:work, pid: "http://doi.org/10.5061/dryad.mf1sd", doi: "10.5061/dryad.mf1sd")
      body = File.read(fixture_path + 'europe_pmc_fulltext_data.xml')
      result = Hash.from_xml(body)
      result.extend Hashie::Extensions::DeepFetch
      response = subject.parse_data(result, work_id: work.id)

      expect(response.length).to eq(1)
      expect(response.first[:relation]).to eq("subj_id"=>"http://europepmc.org/abstract/MED/21765886",
                                              "obj_id"=>work.pid,
                                              "relation_type_id"=>"cites",
                                              "provenance_url"=>"http://europepmc.org/abstract/MED/#{work.pmid}#fragment-related-bioentities",
                                              "source_id"=>"pmc_europe_fulltext_data")

      expect(response.first[:subj]).to eq("pid"=>"http://europepmc.org/abstract/MED/21765886",
                                          "author"=>[{"family"=>"HA.", "given"=>"Piwowar"}],
                                          "title"=>"Who shares? Who doesn't? Factors associated with openly archiving raw research data.",
                                          "container-title"=>"PLoS One",
                                          "issued"=>"2011",
                                          "URL"=>"http://europepmc.org/abstract/MED/21765886",
                                          "type"=>"article-journal",
                                          "tracked"=>false)
    end
  end
end
