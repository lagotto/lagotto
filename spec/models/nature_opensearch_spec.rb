require 'rails_helper'

describe NatureOpensearch, type: :model, vcr: true do
  subject { FactoryGirl.create(:nature_opensearch) }

  let(:work) { FactoryGirl.build(:work, doi: nil, canonical_url: "https://github.com/najoshi/sickle", registration_agency: "github") }

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
      work = FactoryGirl.build(:work, doi: nil, canonical_url: nil)
      expect(subject.get_data(work)).to eq({})
    end

    it "should report if there are no events returned by the Nature OpenSearch API" do
      work = FactoryGirl.build(:work, doi: nil, canonical_url: "https://github.com/pymor/pymor", registration_agency: "github")
      response = subject.get_data(work)
      expect(response["feed"]["opensearch:totalResults"]).to eq(0)
    end

    it "should report if there are events and event_count returned by the Nature OpenSearch API" do
      response = subject.get_data(work)
      expect(response["feed"]["opensearch:totalResults"]).to eq(15)
      expect(response["feed"]["entry"].length).to eq(15)
      result = response["feed"]["entry"].first
      result.extend Hashie::Extensions::DeepFetch
      expect(result.deep_fetch("sru:recordData", "pam:message", "pam:article", "xhtml:head", "prism:doi") { nil }).to eq("10.1038/nature14486")
    end

    it "should catch errors with the Nature OpenSearch API" do
      stub = stub_request(:get, subject.get_query_url(work)).to_return(:status => [408])
      response = subject.get_data(work, options = { :source_id => subject.id })
      expect(response).to eq(error: "the server responded with status 408 for http://www.nature.com/opensearch/request?query=%22#{work.canonical_url}%22&httpAccept=application/json&startRecord=1", status: 408)
      expect(stub).to have_been_requested
      expect(Alert.count).to eq(1)
      alert = Alert.first
      expect(alert.class_name).to eq("Net::HTTPRequestTimeout")
      expect(alert.status).to eq(408)
      expect(alert.source_id).to eq(subject.id)
    end
  end

  context "parse_data" do
    it "should report if the doi and canonical_url are missing" do
      work = FactoryGirl.create(:work, doi: nil, canonical_url: nil)
      result = {}
      expect(subject.parse_data(result, work)).to eq(works: [], events: { source: "nature_opensearch", work: work.pid, total: 0, events_url: nil, days: [], months: [] })
    end

    it "should report if there are no events and event_count returned by the Nature OpenSearch API" do
      body = File.read(fixture_path + 'nature_opensearch_nil.json')
      result = JSON.parse(body)
      expect(subject.parse_data(result, work)).to eq(works: [], events: { source: "nature_opensearch", work: work.pid, total: 0, events_url: nil, days: [], months: [] })
    end

    it "should report if there are events and event_count returned by the Nature OpenSearch API" do
      work = FactoryGirl.build(:work, doi: nil, canonical_url: "https://github.com/rougier/ten-rules", published_on: "2009-03-15")
      body = File.read(fixture_path + 'nature_opensearch.json')
      result = JSON.parse(body)
      response = subject.parse_data(result, work)
      expect(response[:works].length).to eq(7)
      expect(response[:events][:total]).to eq(7)
      expect(response[:events][:days].length).to eq(0)
      expect(response[:events][:months].length).to eq(5)
      expect(response[:events][:months].first).to eq(year: 2013, month: 8, total: 1)

      event = response[:works].last
      expect(event['author']).to eq([{"family"=>"Patro", "given"=>"Rob"}, {"family"=>"Mount", "given"=>"Stephen M"}, {"family"=>"Kingsford", "given"=>"Carl"}])
      expect(event['title']).to eq("Sailfish enables alignment-free isoform quantification from RNA-seq reads using lightweight algorithms")
      expect(event['container-title']).to eq("Nature Biotechnology")
      expect(event['issued']).to eq("date-parts"=>[[2014, 4, 20]])
      expect(event['timestamp']).to eq("2014-04-20T00:00:00Z")
      expect(event['DOI']).to eq("10.1038/nbt.2862")
      expect(event['URL']).to eq("http://dx.doi.org/10.1038/nbt.2862")
      expect(event['type']).to eq("article-journal")
    end

    it "should catch timeout errors with the Nature OpenSearch API" do
      result = { error: "the server responded with status 408 for http://example.org?doi={doi}", status: 408 }
      response = subject.parse_data(result, work)
      expect(response).to eq(result)
    end
  end
end
