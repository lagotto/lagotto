require 'rails_helper'

describe BmcFulltext, type: :model, vcr: true do
  subject { FactoryGirl.create(:bmc_fulltext) }

  let(:work) { FactoryGirl.create(:work, doi: nil, canonical_url: "https://github.com/najoshi/sickle", registration_agency: "github") }

  context "lookup canonical URL" do
    it "should look up canonical URL if there is no work url" do
      work = FactoryGirl.create(:work, :doi => "10.1186/s13007-014-0041-7", :canonical_url => nil)
      #lookup_stub = stub_request(:get, work.doi_as_url).to_return(:status => 404)
      response = subject.get_data(work_id: work.id)
      # TODO JW - no assertion made
      #expect(lookup_stub).to have_been_requested
    end

    it "should not look up canonical URL if there is work url" do
      #lookup_stub = stub_request(:get, work.canonical_url).to_return(:status => 200, :headers => { 'Location' => work.canonical_url })
      #stub = stub_request(:get, subject.get_query_url(work)).to_return(:body => File.read(fixture_path + 'bmc_fulltext.json'))
      response = subject.get_data(work_id: work.id)
      # TODO JW - no assertion made
      #expect(lookup_stub).not_to have_been_requested
      #expect(stub).to have_been_requested
    end
  end

  context "get_data" do
    it "should report that there are no events if the doi and canonical_url are missing" do
      work = FactoryGirl.create(:work, doi: nil, canonical_url: nil)
      expect(subject.get_data(work_id: work.id)).to eq({})
    end

    it "should report if there are no events returned by the BMC Search API" do
      work = FactoryGirl.create(:work, doi: nil, canonical_url: "https://github.com/pymor/pymor", registration_agency: "github")
      response = subject.get_data(work_id: work.id)
      expect(response).to eq({ "entries" => [] })
    end

    it "should report if there are events and event_count returned by the BMC Search API" do
      response = subject.get_data(work_id: work.id)

      expect(response["entries"].length).to eq(25)
      doc = response["entries"].first

      # expect(doc).to include( { "doi" => "10.1186/s12864-015-1724-9" } )

      expect(doc["doi"]).to eq("10.1186/s12864-015-1724-9")
    end

    it "should catch errors with the BMC Search API" do
      stub = stub_request(:get, subject.get_query_url(work_id: work.id)).to_return(:status => [408])
      response = subject.get_data(work_id: work.id, agent_id: subject.id)
      expect(response).to eq(error: "the server responded with status 408 for http://www.biomedcentral.com/search/results?terms=#{subject.get_query_string(work_id: work.id)}&format=json", :status=>408)
      expect(stub).to have_been_requested
      expect(Notification.count).to eq(1)
      notification = Notification.first
      expect(notification.class_name).to eq("Net::HTTPRequestTimeOut")
      expect(notification.status).to eq(408)
      expect(notification.agent_id).to eq(subject.id)
    end
  end

  context "parse_data" do
    it "should report that there are no events if the doi has the wrong prefix" do
      work = FactoryGirl.create(:work, doi: "10.1371/journal.pmed.0020124")
      result = {}

      expect(subject.parse_data(result, work_id: work.id)).to eq([])
    end

    it "should report if there are no events and event_count returned by the BMC Search API" do
      body = File.read(fixture_path + 'bmc_fulltext_nil.json')
      result = JSON.parse(body)
      # expect(subject.parse_data(result, work_id: work.id)).to eq(works: [], events: [{ source_id: "bmc_fulltext", work_id: work.pid, total: 0, events_url: nil, extra: [], months: [] }])
      # TODO JW - should absence report no events or zero totals?      

      expect(subject.parse_data(result, work_id: work.id)).to eq([])
    end

    it "should report if there are events and event_count returned by the BMC Search API" do
      work = FactoryGirl.create(:work, doi: nil, canonical_url: "https://github.com/najoshi/sickle", published_on: "2009-03-15")
      body = File.read(fixture_path + 'bmc_fulltext.json')
      result = JSON.parse(body)
      response = subject.parse_data(result, work_id: work.id)

      # TODO JW - subj_id and obj_id seem to be swapped - by design?
      expect(response.first[:relation]).to include({ "subj_id" => work.pid,
                                                     "obj_id" => "http://doi.org/10.1186/s13007-014-0041-7",
                                                     "relation_type_id" => "cites",
                                                     "source_id" => "bmc_fulltext"})

      expect(response.first[:subj]).to include({ "pid" => "http://doi.org/10.1186/s13007-014-0041-7",
                                                 "author" => [{ "family"=>"Etherington", "given"=>"GJ" },
                                                              { "family"=>"Monaghan", "given"=>"J" },
                                                              { "family"=>"Zipfel", "given"=>"C" },
                                                              { "family"=>"MacLean", "given"=>"D" }],
                                                  "title" => "Mapping mutations in plant genomes with the user-friendly web application CandiSNP",
                                                  "container-title" => "Plant Methods", 
                                                  "issued" => {"date-parts"=>[[2014, 12, 30]]},
                                                  "timestamp" => "2014-12-30T00:00:00Z",
                                                  "DOI" => "10.1186/s13007-014-0041-7",
                                                  "type" => "article-journal",
                                                  "tracked" => false,
                                                  "registration_agency" => "crossref" })

      expect(response.length).to eq(16)      
    end

    it "should catch timeout errors with the BMC Search API" do
      # TODO JW - response isn't defined. How to simulate timeout errors?
      # TODO FAILING
      response = subject.parse_data(result, work_id: work.id)
      expect(response).to eq( { error: "the server responded with status 408 for http://example.org?doi={doi}",
                                status: 408 } )
    end
  end
end
