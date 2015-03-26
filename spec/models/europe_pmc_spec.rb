require 'rails_helper'

describe EuropePmc, type: :model, vcr: true do
  subject { FactoryGirl.create(:europe_pmc) }

  let(:work) { FactoryGirl.build(:work, :pmid => "15723116") }

  context "get_data" do
    it "should report that there are no events if the pmid and doi are missing" do
      work = FactoryGirl.build(:work, doi: nil, :pmid => nil)
      expect(subject.get_data(work)).to eq({})
    end

    it "should report if there are no events and event_count returned by the PMC Europe API" do
      work = FactoryGirl.build(:work, :pmid => "20098740")
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
      work = FactoryGirl.build(:work, :pmid => nil)
      result = {}
      expect(subject.parse_data(result, work)).to eq({})
    end

    it "should report if there are no events and event_count returned by the PMC Europe API" do
      work = FactoryGirl.build(:work, :pmid => "20098740")
      body = File.read(fixture_path + 'europe_pmc_nil.json')
      result = JSON.parse(body)
      expect(subject.parse_data(result, work)).to eq(events: [], :events_by_day=>[], :events_by_month=>[], total: 0, events_url: nil, event_metrics: { pdf: nil, html: nil, shares: nil, groups: nil, comments: nil, likes: nil, citations: 0, total: 0 }, extra: nil)
    end

    it "should report if there are events and event_count returned by the PMC Europe API" do
      body = File.read(fixture_path + 'europe_pmc.json')
      result = JSON.parse(body)
      response = subject.parse_data(result, work)
      expect(response[:total]).to eq(23)
      expect(response[:event_metrics]).to eq(pdf: nil, html: nil, shares: nil, groups: nil, comments: nil, likes: nil, citations: 23, total: 23)
      expect(response[:events_by_day]).to be_empty
      expect(response[:events_by_month]).to be_empty

      event = response[:events].last
      expect(event['author']).to eq([{"family"=>"Wei", "given"=>"D"}, {"family"=>"Jiang", "given"=>"Q"}, {"family"=>"Wei", "given"=>"Y"}, {"family"=>"Wang", "given"=>"S"}])
      expect(event['title']).to eq("A novel hierarchical clustering algorithm for gene sequences")
      expect(event['container-title']).to eq("BMC Bioinformatics")
      expect(event['issued']).to eq("date-parts"=>[[2012]])
      expect(event['URL']).to eq("http://europepmc.org/abstract/MED/22823405")
      expect(event['type']).to eq("article-journal")
    end

    it "should catch timeout errors with the PMC Europe API" do
      work = FactoryGirl.create(:work, :doi => "10.2307/683422")
      result = { error: "the server responded with status 408 for http://www.ebi.ac.uk/europepmc/webservices/rest/MED/#{work.pmid}/citations/1/json", status: 408 }
      response = subject.parse_data(result, work)
      expect(response).to eq(result)
    end
  end
end
