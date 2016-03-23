require 'rails_helper'

describe EuropePmc, type: :model, vcr: true do
  subject { FactoryGirl.create(:europe_pmc) }

  let(:work) { FactoryGirl.create(:work, pmid: "15723116", pmcid: "256885") }

  context "get_data" do
    it "should report that there are no events if the pmid, doi and pmcid are missing" do
      work = FactoryGirl.create(:work, doi: nil, pmid: nil, pmcid: nil)
      expect(subject.get_data(work_id: work.id)).to eq({})
    end

    it "should report if there are no events and event_count returned by the PMC Europe API" do
      work = FactoryGirl.create(:work, :pmid => "20098740", pmcid: "256885")
      response = subject.get_data(work_id: work.id)
      expect(response["hitCount"]).to eq(0)
    end

    it "should report if there are events and event_count returned by the PMC Europe API" do
      response = subject.get_data(work_id: work.id)
      expect(response["hitCount"]).to eq(810)
      expect(response["citationList"]["citation"].length).to eq(810)
      citation = response["citationList"]["citation"].first
      expect(citation["title"]).to eq("Passenger-strand cleavage facilitates assembly of siRNA into Ago2-containing RNAi enzyme complexes.")
    end

    it "should catch errors with the PMC Europe API" do
      stub = stub_request(:get, subject.get_query_url(work_id: work.id)).to_return(:status => [408])
      response = subject.get_data(work_id: work, source_id: subject.source_id)
      expect(response).to eq(error: "the server responded with status 408 for http://www.ebi.ac.uk/europepmc/webservices/rest/MED/#{work.pmid}/citations/1/json", :status=>408)
      expect(stub).to have_been_requested
      expect(Notification.count).to eq(1)
      notification = Notification.first
      expect(notification.class_name).to eq("Net::HTTPRequestTimeOut")
      expect(notification.status).to eq(408)
      expect(notification.source_id).to eq(subject.source_id)
    end
  end

  context "parse_data" do
    it "should report that there are no events if the pmid, doi and pmcid are missing" do
      work = FactoryGirl.create(:work, doi: nil, pmid: nil, pmcid: nil)
      result = {}
      expect(subject.parse_data(result, work_id: work.id)).to eq([])
    end

    it "should report if there are no events and event_count returned by the PMC Europe API" do
      work = FactoryGirl.create(:work, :pmid => "20098740")
      body = File.read(fixture_path + 'europe_pmc_nil.json')
      result = JSON.parse(body)
      expect(subject.parse_data(result, work_id: work.id)).to eq([])
    end

    it "should report if there are events and event_count returned by the PMC Europe API" do
      body = File.read(fixture_path + 'europe_pmc.json')
      result = JSON.parse(body)
      response = subject.parse_data(result, work_id: work.id)

      expect(response.length).to eq(23)
      expect(response.first[:relation]).to eq("subj_id"=>"http://doi.org/10.1124/pr.109.001263",
                                              "obj_id"=>work.pid,
                                              "relation_type_id"=>"cites",
                                              "source_id"=>"pmc_europe")

      expect(response.first[:subj]).to eq("pid"=>"http://doi.org/10.1124/pr.109.001263",
                                          "author"=>[{"family"=>"Romanovsky", "given"=>"AA"},
                                                     {"family"=>"Almeida", "given"=>"MC"},
                                                     {"family"=>"Garami", "given"=>"A"},
                                                     {"family"=>"Steiner", "given"=>"AA"},
                                                     {"family"=>"Norman", "given"=>"MH"},
                                                     {"family"=>"Morrison", "given"=>"SF"},
                                                     {"family"=>"Nakamura", "given"=>"K"},
                                                     {"family"=>"Burmeister", "given"=>"JJ"},
                                                     {"family"=>"Nucci", "given"=>"TB"}],
                                          "title"=>"The transient receptor potential vanilloid-1 channel in thermoregulation: a thermosensor it is not",
                                          "container-title"=>"Pharmacol. Rev.",
                                          "issued"=>{"date-parts"=>[[2009]]},
                                          "DOI"=>"10.1124/pr.109.001263",
                                          "PMID"=>"19749171",
                                          "PMCID"=>"2763780",
                                          "type"=>"article-journal",
                                          "registration_agency"=>"crossref",
                                          "tracked"=>false)
    end

    it "should catch timeout errors with the PMC Europe API" do
      work = FactoryGirl.create(:work, :doi => "10.2307/683422")
      result = { error: "the server responded with status 408 for http://www.ebi.ac.uk/europepmc/webservices/rest/MED/#{work.pmid}/citations/1/json", status: 408 }
      response = subject.parse_data(result, work_id: work.id)
      expect(response).to eq([result])
    end
  end
end
