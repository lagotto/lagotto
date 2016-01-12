require 'rails_helper'

describe EuropePmc, type: :model, vcr: true do
  subject { FactoryGirl.create(:europe_pmc) }

  let(:work) { FactoryGirl.create(:work, :pmid => "15723116") }

  context "get_data" do
    it "should report that there are no events if the pmid, doi and pmcid are missing" do
      work = FactoryGirl.create(:work, doi: nil, :pmid => nil, pmcid: nil)
      expect(subject.get_data(work_id: work.id)).to eq({})
    end

    it "should report if there are no events and event_count returned by the PMC Europe API" do
      work = FactoryGirl.create(:work, :pmid => "20098740")
      response = subject.get_data(work_id: work.id)
      expect(response["hitCount"]).to eq(0)
    end

    it "should report if there are events and event_count returned by the PMC Europe API" do
      response = subject.get_data(work_id: work.id)
      expect(response["hitCount"]).to eq(797)
      expect(response["citationList"]["citation"].length).to eq(797)
      citation = response["citationList"]["citation"].first
      expect(citation["title"]).to eq("Passenger-strand cleavage facilitates assembly of siRNA into Ago2-containing RNAi enzyme complexes.")
    end

    it "should catch errors with the PMC Europe API" do
      stub = stub_request(:get, subject.get_query_url(work_id: work.id)).to_return(:status => [408])
      response = subject.get_data(work_id: work, agent_id: subject.id)
      expect(response).to eq(error: "the server responded with status 408 for http://www.ebi.ac.uk/europepmc/webservices/rest/MED/#{work.pmid}/citations/1/json", :status=>408)
      expect(stub).to have_been_requested
      expect(Notification.count).to eq(1)
      notification = Notification.first
      expect(notification.class_name).to eq("Net::HTTPRequestTimeOut")
      expect(notification.status).to eq(408)
      expect(notification.agent_id).to eq(subject.id)
    end
  end

  context "parse_data" do
    it "should report that there are no events if the pmid is missing" do
      work = FactoryGirl.create(:work, :pmid => nil)
      result = {}
      expect(subject.parse_data(result, work_id: work.id)).to eq({})
    end

    it "should report if there are no events and event_count returned by the PMC Europe API" do
      work = FactoryGirl.create(:work, :pmid => "20098740")
      body = File.read(fixture_path + 'europe_pmc_nil.json')
      result = JSON.parse(body)
      expect(subject.parse_data(result, work_id: work.id)).to eq(works: [], events: [{ source_id: "pmc_europe", work_id: work.pid, total: 0, events_url: nil, days: [], months: [] }])
    end

    it "should report if there are events and event_count returned by the PMC Europe API" do
      body = File.read(fixture_path + 'europe_pmc.json')
      result = JSON.parse(body)
      response = subject.parse_data(result, work_id: work.id)

      event = response[:events].first
      expect(event[:source_id]).to eq("pmc_europe")
      expect(event[:work_id]).to eq(work.pid)
      expect(event[:total]).to eq(23)
      expect(event[:days]).to be_empty
      expect(event[:months]).to be_empty

      expect(response[:works].length).to eq(23)
      related_work = response[:works].last
      expect(related_work['author']).to eq([{"family"=>"Wei", "given"=>"D"}, {"family"=>"Jiang", "given"=>"Q"}, {"family"=>"Wei", "given"=>"Y"}, {"family"=>"Wang", "given"=>"S"}])
      expect(related_work['title']).to eq("A novel hierarchical clustering algorithm for gene sequences")
      expect(related_work['container-title']).to eq("BMC Bioinformatics")
      expect(related_work['issued']).to eq("date-parts"=>[[2012]])
      expect(related_work['DOI']).to eq("10.1186/1471-2105-13-174")
      expect(related_work['PMID']).to eq("22823405")
      expect(related_work['PMCID']).to eq("3443659")
      expect(related_work['type']).to eq("article-journal")
      expect(related_work['related_works']).to eq([{"pid"=>work.pid, "source_id"=>"pmc_europe", "relation_type_id"=>"cites"}])
    end

    it "should catch timeout errors with the PMC Europe API" do
      work = FactoryGirl.create(:work, :doi => "10.2307/683422")
      result = { error: "the server responded with status 408 for http://www.ebi.ac.uk/europepmc/webservices/rest/MED/#{work.pmid}/citations/1/json", status: 408 }
      response = subject.parse_data(result, work_id: work.id)
      expect(response).to eq(result)
    end
  end
end
