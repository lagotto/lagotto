require 'rails_helper'

describe DataciteData, type: :model, vcr: true do
  subject { FactoryGirl.create(:datacite_data) }

  let(:work) { FactoryGirl.create(:work, pid: "http://doi.org/10.5061/DRYAD.8515", doi: "10.5061/DRYAD.8515", registration_agency: "datacite") }

  context "get_data" do
    it "should report that there are no events if the doi is missing" do
      work = FactoryGirl.create(:work, :doi => nil)
      expect(subject.get_data(work_id: work.id)).to eq({})
    end

    it "should report that there are no events if the registration agency is not DataCite" do
      work = FactoryGirl.create(:work)
      expect(subject.get_data(work_id: work.id)).to eq({})
    end

    it "should report if there are no events and event_count returned by the Datacite API" do
      work = FactoryGirl.create(:work, :doi => "10.1371/journal.pone.0043007", registration_agency: "datacite")
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
      response = subject.get_data(work_id: work.id, agent_id: subject.id)
      expect(response).to eq(error: "the server responded with status 408 for http://search.datacite.org/api?q=doi:#{work.doi_escaped}&fl=doi,relatedIdentifier&fq=is_active:true&fq=has_metadata:true&rows=1000&wt=json", :status=>408)
      expect(stub).to have_been_requested
      expect(Notification.count).to eq(1)
      notification = Notification.first
      expect(notification.class_name).to eq("Net::HTTPRequestTimeOut")
      expect(notification.status).to eq(408)
      expect(notification.agent_id).to eq(subject.id)
    end
  end

  context "parse_data" do
    it "should report if the doi is missing" do
      work = FactoryGirl.create(:work, :doi => nil)
      result = {}
      expect(subject.parse_data(result, work_id: work.id)).to eq([])
    end

    it "should report if there are no events and event_count returned by the Datacite API" do
      body = File.read(fixture_path + 'datacite_data_nil.json')
      result = JSON.parse(body)
      expect(subject.parse_data(result, work_id: work.id)).to eq([])
    end

    it "should report if there are events and event_count returned by the Datacite API" do
      body = File.read(fixture_path + 'datacite_data.json')
      result = JSON.parse(body)
      response = subject.parse_data(result, work_id: work.id)

      expect(response.length).to eq(3)
      expect(response.first[:prefix]).to eq("10.5061")
      expect(response.first[:relation]).to eq("subj_id"=>"http://doi.org/10.5061/DRYAD.8515",
                                              "obj_id"=>"http://doi.org/10.5061/DRYAD.8515/1",
                                              "relation_type_id"=>"has_part",
                                              "source_id"=>"datacite_data",
                                              "publisher_id"=>"CDL.DRYAD")

      expect(response.first[:obj]).to eq("pid"=>"http://doi.org/10.5061/DRYAD.8515/1",
                                         "author"=>[{"family"=>"Ollomo", "given"=>"Benjamin"},
                                                    {"family"=>"Durand", "given"=>"Patrick"},
                                                    {"family"=>"Prugnolle", "given"=>"Franck"},
                                                    {"family"=>"Douzery", "given"=>"Emmanuel J. P."},
                                                    {"family"=>"Arnathau", "given"=>"Céline"},
                                                    {"family"=>"Nkoghe", "given"=>"Dieudonné"},
                                                    {"family"=>"Leroy", "given"=>"Eric"},
                                                    {"family"=>"Renaud", "given"=>"François"}],
                                         "title"=>"Ollomo_PLoSPathog_2009",
                                         "container-title"=>"Dryad Digital Repository",
                                         "issued"=>"2011",
                                         "volume"=>nil,
                                         "issue"=>nil,
                                         "page"=>nil,
                                         "DOI"=>"10.5061/DRYAD.8515/1",
                                         "type"=>"dataset",
                                         "tracked"=>true,
                                         "publisher_id"=>"CDL.DRYAD",
                                         "registration_agency"=>"datacite")
    end

    it "should catch timeout errors with the Datacite API" do
      result = { error: "the server responded with status 408 for http://search.datacite.org/api?q=doi:#{work.doi_escaped}&fl=relatedIdentifier,doi,creator,title,publisher,publicationYear&fq=is_active:true&fq=has_metadata:true&indent=true&rows=100&wt=json", status: 408 }
      response = subject.parse_data(result, work_id: work.id)
      expect(response).to eq([result])
    end
  end
end
