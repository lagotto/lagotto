require 'rails_helper'

describe BmcFulltext, type: :model, vcr: true do
  subject { FactoryGirl.create(:bmc_fulltext) }

  let(:work) { FactoryGirl.create(:work, doi: nil, canonical_url: "https://github.com/najoshi/sickle", registration_agency: "github") }

  context "lookup canonical URL" do
    it "should look up canonical URL if there is no work url" do
      work = FactoryGirl.create(:work, :doi => "10.1186/s13007-014-0041-7", :canonical_url => nil)
      #lookup_stub = stub_request(:get, work.doi_as_url).to_return(:status => 404)
      response = subject.get_data(work)
      #expect(lookup_stub).to have_been_requested
    end

    it "should not look up canonical URL if there is work url" do
      #lookup_stub = stub_request(:get, work.canonical_url).to_return(:status => 200, :headers => { 'Location' => work.canonical_url })
      #stub = stub_request(:get, subject.get_query_url(work)).to_return(:body => File.read(fixture_path + 'bmc_fulltext.json'))
      response = subject.get_data(work)
      #expect(lookup_stub).not_to have_been_requested
      #expect(stub).to have_been_requested
    end
  end

  context "get_data" do
    it "should report that there are no events if the doi and canonical_url are missing" do
      work = FactoryGirl.create(:work, doi: nil, canonical_url: nil)
      expect(subject.get_data(work)).to eq({})
    end

    it "should report if there are no events returned by the BMC Search API" do
      work = FactoryGirl.create(:work, doi: nil, canonical_url: "https://github.com/pymor/pymor", registration_agency: "github")
      response = subject.get_data(work)
      expect(response).to eq("entries"=>[])
    end

    it "should report if there are events and event_count returned by the BMC Search API" do
      response = subject.get_data(work)
      expect(response["entries"].length).to eq(24)
      doc = response["entries"].first
      expect(doc["doi"]).to eq("10.1186/s12864-015-1739-2")
    end

    it "should catch errors with the BMC Search API" do
      stub = stub_request(:get, subject.get_query_url(work)).to_return(:status => [408])
      response = subject.get_data(work, options = { :source_id => subject.id })
      expect(response).to eq(error: "the server responded with status 408 for http://www.biomedcentral.com/search/results?terms=#{subject.get_query_string(work)}&format=json", :status=>408)
      expect(stub).to have_been_requested
      expect(Alert.count).to eq(1)
      alert = Alert.first
      expect(alert.class_name).to eq("Net::HTTPRequestTimeOut")
      expect(alert.status).to eq(408)
      expect(alert.source_id).to eq(subject.id)
    end
  end

  context "parse_data" do
    it "should report that there are no events if the doi has the wrong prefix" do
      work = FactoryGirl.create(:work, doi: "10.1371/journal.pmed.0020124")
      result = {}
      expect(subject.parse_data(result, work)).to eq({})
    end

    it "should report if there are no events and event_count returned by the BMC Search API" do
      body = File.read(fixture_path + 'bmc_fulltext_nil.json')
      result = JSON.parse(body)
      expect(subject.parse_data(result, work)).to eq(works: [], events: { source: "bmc_fulltext", work: work.pid, total: 0, events_url: nil, extra: [], days: [], months: [] })
    end

    it "should report if there are events and event_count returned by the BMC Search API" do
      work = FactoryGirl.create(:work, doi: nil, canonical_url: "https://github.com/najoshi/sickle", published_on: "2009-03-15")
      body = File.read(fixture_path + 'bmc_fulltext.json')
      result = JSON.parse(body)
      response = subject.parse_data(result, work)
      expect(response[:works].length).to eq(16)
      expect(response[:events][:total]).to eq(16)
      expect(response[:events][:events_url]).to eq("http://www.biomedcentral.com/search/results?terms=https://github.com/najoshi/sickle")
      expect(response[:events][:days].length).to eq(9)
      expect(response[:events][:days].first).to eq(year: 2013, month: 1, day: 30, total: 1)
      expect(response[:events][:months].length).to eq(11)
      expect(response[:events][:months].first).to eq(year: 2013, month: 1, total: 1)

      event = response[:works].first
      expect(event['author']).to eq([{"family"=>"Etherington", "given"=>"Gj"}, {"family"=>"Monaghan", "given"=>"J"}, {"family"=>"Zipfel", "given"=>"C"}, {"family"=>"Mac Lean", "given"=>"D"}])
      expect(event['title']).to eq("Mapping mutations in plant genomes with the user-friendly web application CandiSNP")
      expect(event['container-title']).to eq("Plant Methods")
      expect(event['issued']).to eq("date-parts"=>[[2014, 12, 30]])
      expect(event['type']).to eq("article-journal")
      expect(event['DOI']).to eq("10.1186/s13007-014-0041-7")
      expect(event['timestamp']).to eq("2014-12-30T00:00:00Z")
      expect(event['related_works']).to eq([{"related_work"=> work.pid, "source"=>"bmc_fulltext", "relation_type"=>"cites"}])

      extra = response[:events][:extra].first
      expect(extra[:event_time]).to eq("2014-12-30T00:00:00Z")
      expect(extra[:event_csl]['author']).to eq([{"family"=>"Etherington", "given"=>"Gj"}, {"family"=>"Monaghan", "given"=>"J"}, {"family"=>"Zipfel", "given"=>"C"}, {"family"=>"Mac Lean", "given"=>"D"}])
      expect(extra[:event_csl]['title']).to eq("Mapping mutations in plant genomes with the user-friendly web application CandiSNP")
      expect(extra[:event_csl]['container-title']).to eq("Plant Methods")
      expect(extra[:event_csl]['issued']).to eq("date-parts"=>[[2014, 12, 30]])
      expect(extra[:event_csl]['type']).to eq("article-journal")
    end

    it "should catch timeout errors with the BMC Search API" do
      result = { error: "the server responded with status 408 for http://example.org?doi={doi}", status: 408 }
      response = subject.parse_data(result, work)
      expect(response).to eq(result)
    end
  end
end
