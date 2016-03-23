require 'rails_helper'

describe Datacite, type: :model, vcr: true do
  subject { FactoryGirl.create(:datacite) }

  let(:work) { FactoryGirl.create(:work, pid: "http://doi.org/10.1371/journal.ppat.1000446", doi: "10.1371/journal.ppat.1000446") }

  context "get_data" do
    it "should report that there are no events if the doi is missing" do
      work = FactoryGirl.create(:work, :doi => nil)
      expect(subject.get_data(work_id: work.id)).to eq({})
    end

    it "should report if there are no events and event_count returned by the Datacite API" do
      work = FactoryGirl.create(:work, :doi => "10.1371/journal.pone.0043007")
      response = subject.get_data(work_id: work.id)
      expect(response["response"]["numFound"]).to eq(0)
      expect(response["response"]["docs"]).to be_empty
    end

    it "should report if there are events and event_count returned by the Datacite API" do
      response = subject.get_data(work_id: work.id)
      expect(response["response"]["numFound"]).to eq(1)
      doc = response["response"]["docs"].first
      expect(doc["doi"]).to eq("10.5061/DRYAD.8515")
    end

    it "should catch timeout errors with the Datacite API" do
      stub = stub_request(:get, subject.get_query_url(work_id: work.id)).to_return(:status => [408])
      response = subject.get_data(work_id: work.id, source_id: subject.source_id)
      expect(response).to eq(error: "the server responded with status 408 for http://search.datacite.org/api?q=relatedIdentifier:#{work.doi_escaped}&fl=doi,creator,title,publisher,publicationYear,resourceTypeGeneral,datacentre,datacentre_symbol,prefix,relatedIdentifier&fq=is_active:true&fq=has_metadata:true&rows=1000&wt=json", :status=>408)
      expect(stub).to have_been_requested
      expect(Notification.count).to eq(1)
      notification = Notification.first
      expect(notification.class_name).to eq("Net::HTTPRequestTimeOut")
      expect(notification.status).to eq(408)
    end
  end

  context "parse_data" do
    it "should report if the doi is missing" do
      work = FactoryGirl.create(:work, :doi => nil)
      result = {}
      expect(subject.parse_data(result, work_id: work.id)).to eq([])
    end

    it "should report if there are no events and event_count returned by the Datacite API" do
      body = File.read(fixture_path + 'datacite_nil.json')
      result = JSON.parse(body)
      expect(subject.parse_data(result, work_id: work.id)).to eq([])
    end

    it "should report if there are events and event_count returned by the Datacite API" do
      body = File.read(fixture_path + 'datacite.json')
      result = JSON.parse(body)
      response = subject.parse_data(result, work_id: work.id)

      expect(response.length).to eq(1)
      expect(response.first[:prefix]).to eq("10.1371")
      expect(response.first[:relation]).to eq("subj_id"=>"http://doi.org/10.5061/DRYAD.8515",
                                              "obj_id"=>work.pid,
                                              "relation_type_id"=>"is_referenced_by",
                                              "source_id"=>"datacite",
                                              "publisher_id"=>"CDL.DRYAD")

      expect(response.first[:subj]).to eq("pid"=>"http://doi.org/10.5061/DRYAD.8515",
                                          "author"=>[{"family"=>"Ollomo", "given"=>"Benjamin"},
                                                     {"family"=>"Durand", "given"=>"Patrick"},
                                                     {"family"=>"Prugnolle", "given"=>"Franck"},
                                                     {"family"=>"Douzery", "given"=>"Emmanuel J. P."},
                                                     {"family"=>"Arnathau", "given"=>"Céline"},
                                                     {"family"=>"Nkoghe", "given"=>"Dieudonné"},
                                                     {"family"=>"Leroy", "given"=>"Eric"},
                                                     {"family"=>"Renaud", "given"=>"François"}],
                                          "title"=>"Data from: A new malaria agent in African hominids",
                                          "container-title"=>"Dryad Digital Repository",
                                          "issued"=>"2011",
                                          "publisher_id"=>"CDL.DRYAD",
                                          "DOI"=>"10.5061/DRYAD.8515",
                                          "type"=>"dataset",
                                          "tracked"=>false,
                                          "registration_agency"=>"datacite")
    end

    it "should catch timeout errors with the Datacite Metadata Search API" do
      result = { error: "the server responded with status 408 for http://search.datacite.org/api?q=relatedIdentifier:#{work.doi_escaped}&fl=relatedIdentifier,doi,creator,title,publisher,publicationYear&fq=is_active:true&fq=has_metadata:true&indent=true&rows=100&wt=json", status: 408 }
      response = subject.parse_data(result, work_id: work.id)
      expect(response).to eq([result])
    end
  end
end
