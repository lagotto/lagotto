require 'rails_helper'

describe EuropePmcFulltext, type: :model, vcr: true do
  subject { FactoryGirl.create(:europe_pmc_fulltext) }

  let(:work) { FactoryGirl.create(:work, doi: nil, canonical_url: "https://github.com/najoshi/sickle", registration_agency: "github") }

  context "lookup canonical URL" do
    it "should look up canonical URL if there is no work url" do
      work = FactoryGirl.create(:work, :doi => "10.1371/journal.pone.0043007", :canonical_url => nil)
      lookup_stub = stub_request(:get, work.doi_as_url).to_return(:status => 404)
      response = subject.get_data(work)
      expect(lookup_stub).to have_been_requested
    end

    it "should not look up canonical URL if there is work url" do
      lookup_stub = stub_request(:get, work.canonical_url).to_return(:status => 200, :headers => { 'Location' => work.canonical_url })
      stub = stub_request(:get, subject.get_query_url(work)).to_return(:body => File.read(fixture_path + 'europe_pmc_fulltext.json'))
      response = subject.get_data(work)
      expect(lookup_stub).not_to have_been_requested
      expect(stub).to have_been_requested
    end
  end

  context "get_data" do
    it "should report that there are no events if the doi and canonical_url are missing" do
      work = FactoryGirl.create(:work, doi: nil, canonical_url: nil)
      expect(subject.get_data(work)).to eq({})
    end

    it "should report if there are no events returned by the Europe PMC Search API" do
      work = FactoryGirl.create(:work, doi: nil, canonical_url: "https://github.com/pymor/pymor", registration_agency: "github")
      response = subject.get_data(work)
      expect(response["hitCount"]).to eq(0)
    end

    it "should report if there are events and event_count returned by the Europe PMC Search API" do
      response = subject.get_data(work)
      expect(response["hitCount"]).to eq(85)
      expect(response["resultList"]["result"].length).to eq(85)
      result = response["resultList"]["result"].first
      expect(result["doi"]).to eq("10.1186/s12859-015-0546-8")
    end

    it "should catch errors with the Europe PMC Search API" do
      stub = stub_request(:get, subject.get_query_url(work)).to_return(:status => [408])
      response = subject.get_data(work, options = { :source_id => subject.id })
      expect(response).to eq(error: "the server responded with status 408 for http://www.ebi.ac.uk/europepmc/webservices/rest/search/query=%22#{work.canonical_url}%22%20OR%20REF:%22#{work.canonical_url}%22&format=json&page=1", status: 408)
      expect(stub).to have_been_requested
      expect(Alert.count).to eq(1)
      alert = Alert.first
      expect(alert.class_name).to eq("Net::HTTPRequestTimeout")
      expect(alert.status).to eq(408)
      expect(alert.source_id).to eq(subject.id)
    end
  end

  context "parse_data" do
    it "should report if there are no events and event_count returned by the Europe PMC Search API" do
      body = File.read(fixture_path + 'europe_pmc_fulltext_nil.json')
      result = JSON.parse(body)
      expect(subject.parse_data(result, work)).to eq(works: [], events: { source: "europe_pmc_fulltext", work: work.pid, total: 0, events_url: nil, days: [], months: [] })
    end

    it "should report if there are events and event_count returned by the Europe PMC Search API" do
      work = FactoryGirl.create(:work, doi: nil, canonical_url: "https://github.com/rougier/ten-rules", published_on: "2009-03-15")
      body = File.read(fixture_path + 'europe_pmc_fulltext.json')
      result = JSON.parse(body)
      response = subject.parse_data(result, work)
      expect(response[:works].length).to eq(13)
      expect(response[:events][:total]).to eq(13)
      expect(response[:events][:days]).to be_empty
      expect(response[:events][:months]).to be_empty

      event = response[:works].last
      expect(event['author']).to eq([{"family"=>"Richardson", "given"=>"Mf"}, {"family"=>"Weinert", "given"=>"La"}, {"family"=>"Welch", "given"=>"Jj"}, {"family"=>"Linheiro", "given"=>"Rs"}, {"family"=>"Magwire", "given"=>"Mm"}, {"family"=>"Jiggins", "given"=>"Fm"}, {"family"=>"Bergman", "given"=>"Cm"}])
      expect(event['title']).to eq("Population genomics of the Wolbachia endosymbiont in Drosophila melanogaster")
      expect(event['container-title']).to eq("PLoS Genet")
      expect(event['issued']).to eq("date-parts"=>[[2012]])
      expect(event['type']).to eq("article-journal")
    end

    it "should catch timeout errors with the Europe PMC Search API" do
      result = { error: "the server responded with status 408 for http://example.org?doi={doi}", status: 408 }
      response = subject.parse_data(result, work)
      expect(response).to eq(result)
    end
  end
end
