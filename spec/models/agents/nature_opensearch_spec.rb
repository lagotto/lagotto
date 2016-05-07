require 'rails_helper'

describe NatureOpensearch, type: :model, vcr: true do
  subject { FactoryGirl.create(:nature_opensearch) }

  let(:work) { FactoryGirl.create(:work, :with_github, doi: nil, canonical_url: "https://github.com/najoshi/sickle") }

  context "lookup canonical URL" do
    it "should look up canonical URL if there is no work url" do
      work = FactoryGirl.create(:work, :with_datacite, :doi => "10.1594/PANGAEA.815864", :canonical_url => nil)
      lookup_stub = stub_request(:get, work.doi_as_url(work.doi)).to_return(:status => 404)
      response = subject.get_data(work_id: work.id)
      expect(lookup_stub).to have_been_requested.twice()
    end

    it "should not look up canonical URL if there is work url" do
      lookup_stub = stub_request(:get, work.canonical_url).to_return(:status => 200, :headers => { 'Location' => work.canonical_url })
      stub = stub_request(:get, subject.get_query_url(work_id: work.id)).to_return(:body => File.read(fixture_path + 'nature_opensearch.json'))
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

    it "should report if there are no events returned by the Nature OpenSearch API" do
      work = FactoryGirl.create(:work, :with_github, doi: nil, canonical_url: "https://github.com/pymor/pymor")
      response = subject.get_data(work_id: work.id)
      expect(response["feed"]["opensearch:totalResults"]).to eq(0)
    end

    it "should report if there are events and event_count returned by the Nature OpenSearch API" do
      response = subject.get_data(work_id: work.id)
      expect(response["feed"]["opensearch:totalResults"]).to eq(30)
      expect(response["feed"]["entry"].length).to eq(25)
      result = response["feed"]["entry"].first
      result.extend Hashie::Extensions::DeepFetch
      expect(result.deep_fetch("sru:recordData", "pam:message", "pam:article", "xhtml:head", "prism:doi") { nil }).to eq("10.1038/nature14486")
    end

    it "should catch errors with the Nature OpenSearch API" do
      stub = stub_request(:get, subject.get_query_url(work_id: work.id)).to_return(:status => [408])
      response = subject.get_data(work_id: work, source_id: subject.source_id)
      expect(response).to eq(error: "the server responded with status 408 for http://www.nature.com/opensearch/request?query=%22#{work.canonical_url}%22&httpAccept=application/json&startRecord=1", status: 408)
      expect(stub).to have_been_requested
      expect(Notification.count).to eq(1)
      notification = Notification.first
      expect(notification.class_name).to eq("Net::HTTPRequestTimeOut")
      expect(notification.status).to eq(408)
    end
  end

  context "parse_data" do
    it "should report if the doi and canonical_url are missing" do
      work = FactoryGirl.create(:work, doi: nil, canonical_url: nil)
      result = {}
      expect(subject.parse_data(result, work_id: work.id)).to eq([])
    end

    it "should report if there are no events and event_count returned by the Nature OpenSearch API" do
      body = File.read(fixture_path + 'nature_opensearch_nil.json')
      result = JSON.parse(body)
      expect(subject.parse_data(result, work_id: work.id)).to eq([])
    end

    it "should report if there are events and event_count returned by the Nature OpenSearch API" do
      work = FactoryGirl.create(:work, :with_github, doi: nil, canonical_url: "https://github.com/rougier/ten-rules", published_on: "2009-03-15")
      body = File.read(fixture_path + 'nature_opensearch.json')
      result = JSON.parse(body)
      response = subject.parse_data(result, work_id: work.id)

      expect(response.length).to eq(7)
      expect(response.first[:relation]).to eq("subj_id"=>"http://doi.org/10.1038/ismej.2014.200",
                                              "obj_id"=>work.pid,
                                              "relation_type_id"=>"cites",
                                              "provenance_url"=>"http://www.nature.com/search?q=%22https://github.com/rougier/ten-rules%22",
                                              "source_id"=>"nature_opensearch")

      expect(response.first[:subj]).to eq("pid"=>"http://doi.org/10.1038/ismej.2014.200",
                                          "author"=>[{"family"=>"Goltsman", "given"=>"Daniela S Aliaga"},
                                                     {"family"=>"Comolli", "given"=>"Luis R"},
                                                     {"family"=>"Thomas", "given"=>"Brian C"},
                                                     {"family"=>"Banfield", "given"=>"Jillian F"}],
                                          "title"=>"Community transcriptomics reveals unexpected high microbial diversity in acidophilic biofilm communities",
                                          "container-title"=>"The ISME Journal",
                                          "issued"=>"2014-11-04T00:00:00Z",
                                          "DOI"=>"10.1038/ismej.2014.200",
                                          "type"=>"article-journal",
                                          "tracked"=>true,
                                          "registration_agency_id"=>"crossref")
    end

    it "should catch timeout errors with the Nature OpenSearch API" do
      result = { error: "the server responded with status 408 for http://example.org?doi={doi}", status: 408 }
      response = subject.parse_data(result, work_id: work.id)
      expect(response).to eq([result])
    end
  end
end
