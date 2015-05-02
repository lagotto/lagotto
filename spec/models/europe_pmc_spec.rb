require 'rails_helper'

describe EuropePmc, type: :model, vcr: true do
  subject { FactoryGirl.create(:europe_pmc) }

  let(:work) { FactoryGirl.create(:work, :pmid => "15723116") }

  context "get_data" do
    it "should report that there are no events if the pmid, doi and pmcid are missing" do
      work = FactoryGirl.create(:work, doi: nil, :pmid => nil, pmcid: nil)
      expect(subject.get_data(work)).to eq({})
    end

    it "should report if there are no events and event_count returned by the PMC Europe API" do
      work = FactoryGirl.create(:work, :pmid => "20098740")
      response = subject.get_data(work)
      expect(response["hitCount"]).to eq(0)
    end

    it "should report if there are events and event_count returned by the PMC Europe API" do
      response = subject.get_data(work)
      expect(response["hitCount"]).to eq(754)
      expect(response["citationList"]["citation"].length).to eq(754)
      citation = response["citationList"]["citation"].first
      expect(citation["title"]).to eq("MicroRNAs: target recognition and regulatory functions.")
    end

    it "should catch errors with the PMC Europe API" do
      stub = stub_request(:get, subject.get_query_url(work)).to_return(:status => [408])
      response = subject.get_data(work, source_id: subject.id)
      expect(response).to eq(error: "the server responded with status 408 for http://www.ebi.ac.uk/europepmc/webservices/rest/MED/#{work.pmid}/citations/1/json", :status=>408)
      expect(stub).to have_been_requested
      expect(Alert.count).to eq(1)
      alert = Alert.first
      expect(alert.class_name).to eq("Net::HTTPRequestTimeOut")
      expect(alert.status).to eq(408)
      expect(alert.source_id).to eq(subject.id)
    end
  end

  context "parse_data" do
    it "should report that there are no events if the pmid is missing" do
      work = FactoryGirl.create(:work, :pmid => nil)
      result = {}
      expect(subject.parse_data(result, work)).to eq({})
    end

    it "should report if there are no events and event_count returned by the PMC Europe API" do
      work = FactoryGirl.create(:work, :pmid => "20098740")
      body = File.read(fixture_path + 'europe_pmc_nil.json')
      result = JSON.parse(body)
      expect(subject.parse_data(result, work)).to eq(works: [], events: { source: "europe_pmc", work: work.pid, total: 0, events_url: nil, days: [], months: [] })
    end

    it "should report if there are events and event_count returned by the PMC Europe API" do
      body = File.read(fixture_path + 'europe_pmc.json')
      result = JSON.parse(body)
      response = subject.parse_data(result, work)
      expect(response[:works].length).to eq(23)
      expect(response[:events][:total]).to eq(23)
      expect(response[:events][:days]).to be_empty
      expect(response[:events][:months]).to be_empty

      event = response[:works].last
      expect(event['author']).to eq([{"family"=>"Wei", "given"=>"D"}, {"family"=>"Jiang", "given"=>"Q"}, {"family"=>"Wei", "given"=>"Y"}, {"family"=>"Wang", "given"=>"S"}])
      expect(event['title']).to eq("A novel hierarchical clustering algorithm for gene sequences")
      expect(event['container-title']).to eq("BMC Bioinformatics")
      expect(event['issued']).to eq("date-parts"=>[[2012]])
      expect(event['DOI']).to eq("10.1186/1471-2105-13-174")
      expect(event['PMID']).to eq("22823405")
      expect(event['PMCID']).to eq("3443659")
      expect(event['type']).to eq("article-journal")
      expect(event['related_works']).to eq([{"related_work"=>work.pid, "source"=>"europe_pmc", "relation_type"=>"cites"}])
    end

    it "should catch timeout errors with the PMC Europe API" do
      work = FactoryGirl.create(:work, :doi => "10.2307/683422")
      result = { error: "the server responded with status 408 for http://www.ebi.ac.uk/europepmc/webservices/rest/MED/#{work.pmid}/citations/1/json", status: 408 }
      response = subject.parse_data(result, work)
      expect(response).to eq(result)
    end
  end
end
