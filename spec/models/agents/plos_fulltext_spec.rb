require 'rails_helper'

describe PlosFulltext, type: :model, vcr: true do
  subject { FactoryGirl.create(:plos_fulltext) }

  let(:work) { FactoryGirl.create(:work, :with_github, doi: nil, canonical_url: "https://github.com/rougier/ten-rules") }

  context "urls" do
    it "should get_query_url" do
      expect(subject.get_query_url(work_id: work.id)).to eq("http://api.plos.org/search?q=everything:%22https://github.com/rougier/ten-rules%22&fq=doc_type:full&fl=id,publication_date,title,cross_published_journal_name,author_display&wt=json&rows=1000")
    end

    it "should get_provenance_url" do
      expect(subject.get_provenance_url(work_id: work.id)).to eq("http://www.plosone.org/search/advanced?unformattedQuery=everything:%22https://github.com/rougier/ten-rules%22")
    end
  end

  context "lookup canonical URL" do
    it "should look up canonical URL if there is no work url" do
      work = FactoryGirl.create(:work, :doi => "10.1371/journal.pone.0043007", :canonical_url => nil)
      response = subject.get_data(work_id: work.id)
    end

    it "should not look up canonical URL if there is work url" do
      #lookup_stub = stub_request(:get, work.canonical_url).to_return(:status => 200, :headers => { 'Location' => work.canonical_url })
      #stub = stub_request(:get, subject.get_query_url(work)).to_return(:body => File.read(fixture_path + 'plos_fulltext.json'))
      response = subject.get_data(work_id: work.id)
      #expect(lookup_stub).not_to have_been_requested
      #expect(stub).to have_been_requested
    end
  end

  context "get_data" do
    it "should report that there are no events if the doi and canonical_url are missing" do
      work = FactoryGirl.create(:work, doi: nil, canonical_url: nil)
      expect(subject.get_data(work_id: work.id)).to eq({})
    end

    it "should report if there are no events returned by the PLOS Search API" do
      work = FactoryGirl.create(:work, :with_github, doi: nil, canonical_url: "https://github.com/pymor/pymor")
      response = subject.get_data(work_id: work.id)
      expect(response["response"]["numFound"]).to eq(0)
    end

    it "should report if there are events returned by the PLOS Search API" do
      response = subject.get_data(work_id: work.id)
      expect(response["response"]["numFound"]).to eq(1)
      doc = response["response"]["docs"].first
      expect(doc["id"]).to eq("10.1371/journal.pcbi.1003833")
    end

    it "should catch errors with the PLOS Search API" do
      stub = stub_request(:get, subject.get_query_url(work_id: work.id)).to_return(:status => [408])
      response = subject.get_data(work_id: work.id, source_id: subject.source_id)
      expect(response).to eq(error: "the server responded with status 408 for http://api.plos.org/search?q=#{subject.get_query_string(work_id: work.id)}&fq=doc_type:full&fl=id,publication_date,title,cross_published_journal_name,author_display&wt=json&rows=1000", :status=>408)
      expect(stub).to have_been_requested
      expect(Notification.count).to eq(1)
      notification = Notification.first
      expect(notification.class_name).to eq("Net::HTTPRequestTimeOut")
      expect(notification.status).to eq(408)
    end
  end

  context "parse_data" do
     it "should report that there are no events if the doi has the wrong prefix" do
      work = FactoryGirl.create(:work, doi: "10.1371/journal.pmed.0020124")
      result = {}
      expect(subject.parse_data(result, work_id: work.id)).to eq([])
    end

    it "should report if there are no events returned by the PLOS Search API" do
      body = File.read(fixture_path + 'plos_fulltext_nil.json')
      result = JSON.parse(body)
      expect(subject.parse_data(result, work_id: work.id)).to eq([])
    end

    it "should report if there are events returned by the PLOS Search API" do
      work = FactoryGirl.create(:work, :with_github, doi: nil, pid: "https://github.com/rougier/ten-rules", canonical_url: "https://github.com/rougier/ten-rules", published_on: "2009-03-15")
      body = File.read(fixture_path + 'plos_fulltext.json')
      result = JSON.parse(body)
      response = subject.parse_data(result, work_id: work.id)

      expect(response.length).to eq(1)
      expect(response.first[:relation]).to eq("subj_id"=>"http://doi.org/10.1371/journal.pcbi.1003833",
                                              "obj_id"=>work.pid,
                                              "relation_type_id"=>"cites",
                                              "provenance_url"=> "http://www.plosone.org/search/advanced?unformattedQuery=everything:%22https://github.com/rougier/ten-rules%22",
                                              "source_id"=>"plos_fulltext")

      expect(response.first[:subj]).to eq("pid"=>"http://doi.org/10.1371/journal.pcbi.1003833",
                                          "author"=>[{"family"=>"Rougier", "given"=>"Nicolas P."},
                                                     {"family"=>"Droettboom", "given"=>"Michael"},
                                                     {"family"=>"Bourne", "given"=>"Philip E."}],
                                          "title"=>"Ten Simple Rules for Better Figures",
                                          "container-title"=>"PLOS Computational Biology",
                                          "issued"=>"2014-09-11T00:00:00Z",
                                          "DOI"=>"10.1371/journal.pcbi.1003833",
                                          "type"=>"article-journal",
                                          "tracked"=>false,
                                          "registration_agency_id"=>"crossref")
    end

    it "should catch timeout errors with the PLOS Search API" do
      result = { error: "the server responded with status 408 for http://example.org?doi={doi}", status: 408 }
      response = subject.parse_data(result, work_id: work.id)
      expect(response).to eq([result])
    end
  end
end
