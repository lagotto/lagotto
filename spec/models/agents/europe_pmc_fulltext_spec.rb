require 'rails_helper'

describe EuropePmcFulltext, type: :model, vcr: true do
  subject { FactoryGirl.create(:europe_pmc_fulltext) }

  let(:work) { FactoryGirl.create(:work, :with_github, doi: nil, canonical_url: "https://github.com/najoshi/sickle") }

  context "lookup canonical URL" do
    it "should look up canonical URL if there is no work url" do
      work = FactoryGirl.create(:work, pid: "http://doi.org/10.1371/journal.pone.0043007", doi: "10.1371/journal.pone.0043007", :canonical_url => nil)
      lookup_stub = stub_request(:get, work.doi_as_url(work.doi)).to_return(:status => 404)
      response = subject.get_data(work_id: work.id)
      expect(lookup_stub).to have_been_requested.twice()
    end

    it "should not look up canonical URL if there is work url" do
      lookup_stub = stub_request(:get, work.canonical_url).to_return(:status => 200, :headers => { 'Location' => work.canonical_url })
      stub = stub_request(:get, subject.get_query_url(work_id: work.id)).to_return(:body => File.read(fixture_path + 'europe_pmc_fulltext.json'))
      response = subject.get_data(work_id: work.id)
      expect(lookup_stub).not_to have_been_requested
      expect(stub).to have_been_requested
    end
  end

  context "get_data" do
    it "should report that there are no events if the doi and canonical_url are missing" do
      work = FactoryGirl.create(:work, doi: nil, canonical_url: nil)
      expect(subject.get_data(work_id: work.id)).to eq({})
    end

    it "should report if there are no events returned by the Europe PMC Search API" do
      work = FactoryGirl.create(:work, :with_github, doi: nil, canonical_url: "https://github.com/pymor/pymor")
      response = subject.get_data(work_id: work.id)
      expect(response["hitCount"]).to eq(0)
    end

    it "should report if there are events and event_count returned by the Europe PMC Search API" do
      response = subject.get_data(work_id: work.id)
      expect(response["hitCount"]).to eq(145)
      expect(response["resultList"]["result"].length).to eq(145)
      result = response["resultList"]["result"].first
      expect(result["doi"]).to eq("10.1128/genomea.01646-15")
    end

    it "should catch errors with the Europe PMC Search API" do
      stub = stub_request(:get, subject.get_query_url(work_id: work.id)).to_return(:status => [408])
      response = subject.get_data(work_id: work.id, source_id: subject.source_id)
      expect(response).to eq(error: "the server responded with status 408 for http://www.ebi.ac.uk/europepmc/webservices/rest/search/query=%22#{work.canonical_url}%22%20OR%20REF:%22#{work.canonical_url}%22&format=json&page=1", status: 408)
      expect(stub).to have_been_requested
      expect(Notification.count).to eq(1)
      notification = Notification.first
      expect(notification.class_name).to eq("Net::HTTPRequestTimeOut")
      expect(notification.status).to eq(408)
    end
  end

  context "parse_data" do
    it "should report if there are no events and event_count returned by the Europe PMC Search API" do
      body = File.read(fixture_path + 'europe_pmc_fulltext_nil.json')
      result = JSON.parse(body)
      expect(subject.parse_data(result, work_id: work.id)).to eq([])
    end

    it "should report if there are events and event_count returned by the Europe PMC Search API" do
      work = FactoryGirl.create(:work, doi: nil, canonical_url: "https://github.com/rougier/ten-rules", published_on: "2009-03-15")
      body = File.read(fixture_path + 'europe_pmc_fulltext.json')
      result = JSON.parse(body)
      response = subject.parse_data(result, work_id: work.id)

      expect(response.length).to eq(13)
      expect(response.first[:relation]).to eq("subj_id"=>"http://doi.org/10.1038/srep05994",
                                              "obj_id"=>work.pid,
                                              "relation_type_id"=>"cites",
                                              "source_id"=>"europe_pmc_fulltext")

      expect(response.first[:subj]).to eq("pid"=>"10.1038/srep05994",
                                          "author"=>[{"family"=>"Martiniano", "given"=>"R"},
                                                     {"family"=>"Coelho", "given"=>"C"},
                                                     {"family"=>"Ferreira", "given"=>"MT"},
                                                     {"family"=>"Neves", "given"=>"MJ"},
                                                     {"family"=>"Pinhasi", "given"=>"R"},
                                                     {"family"=>"Bradley", "given"=>"DG"}],
                                          "title"=>"Genetic evidence of African slavery at the beginning of the trans-Atlantic slave trade",
                                          "container-title"=>"Sci Rep",
                                          "issued"=>"2014",
                                          "DOI"=>"10.1038/srep05994",
                                          "PMID"=>"25104065",
                                          "PMCID"=>"4125989",
                                          "type"=>"article-journal",
                                          "tracked"=>false,
                                          "registration_agency_id"=>"crossref")
    end

    it "should catch timeout errors with the Europe PMC Search API" do
      result = { error: "the server responded with status 408 for http://example.org?doi={doi}", status: 408 }
      response = subject.parse_data(result, work_id: work.id)
      expect(response).to eq([result])
    end
  end
end
