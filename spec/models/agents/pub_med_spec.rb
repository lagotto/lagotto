require 'rails_helper'

describe PubMed, type: :model, vcr: true do
  subject { FactoryGirl.create(:pub_med) }

  let(:work) { FactoryGirl.create(:work, :doi => "10.1371/journal.pone.0000001", :pmid => "17183631", :pmcid => "1762328") }

  context "get_data" do
    it "should report that there are no events if the doi, pmid and pmcid are missing" do
      work = FactoryGirl.create(:work, doi: nil, pmid: nil, pmcid: nil)
      expect(subject.get_data(work_id: work.id)).to eq({})
    end

    it "should report if there are no events and event_count returned by the PubMed API" do
      work = FactoryGirl.create(:work, :doi => "10.1371/journal.pone.0008776", :pmid => "1897483599", :pmcid => "2808249")
      response = subject.get_data(work_id: work.id)
      expect(response["PubMedToPMCcitingformSET"]["REFORM"]["PMCID"]).to be_nil
    end

    it "should report if there are events and event_count returned by the PubMed API" do
      response = subject.get_data(work_id: work.id)
      expect(response["PubMedToPMCcitingformSET"]["REFORM"]["PMCID"].length).to eq(18)
      expect(response["PubMedToPMCcitingformSET"]["REFORM"]["PMCID"].first).to eq("2464333")
    end

    it "should catch errors with the PubMed API" do
      stub = stub_request(:get, subject.get_query_url(work_id: work.id)).to_return(:status => [408])
      response = subject.get_data(work_id: work, source_id: subject.source_id)
      expect(response).to eq(error: "the server responded with status 408 for http://www.ncbi.nlm.nih.gov/pmc/utils/entrez2pmcciting.cgi?view=xml&id=#{work.pmid}", :status=>408)
      expect(stub).to have_been_requested
      expect(Notification.count).to eq(1)
      notification = Notification.first
      expect(notification.class_name).to eq("Net::HTTPRequestTimeOut")
      expect(notification.status).to eq(408)
    end
  end

  context "parse_data" do
    it "should report that there are no events if the pmid is missing" do
      work = FactoryGirl.create(:work, :pmid => "")
      result = {}
      result.extend Hashie::Extensions::DeepFetch
      expect(subject.parse_data(result, work_id: work.id)).to eq([])
    end

    it "should report if there are no events and event_count returned by the PubMed API" do
      work = FactoryGirl.create(:work, :doi => "10.1371/journal.pone.0008776", :pmid => "1897483599", :pmcid => "2808249")
      body = File.read(fixture_path + 'pub_med_nil.xml')
      result = Hash.from_xml(body)
      result.extend Hashie::Extensions::DeepFetch
      response = subject.parse_data(result, work_id: work.id)
      expect(subject.parse_data(result, work_id: work.id)).to eq([])
    end

    it "should report if there are events and event_count returned by the PubMed API" do
      body = File.read(fixture_path + 'pub_med.xml')
      result = Hash.from_xml(body)
      result.extend Hashie::Extensions::DeepFetch
      response = subject.parse_data(result, work_id: work.id)

      expect(response.length).to eq(13)
      expect(response.first[:relation]).to eq("subj_id"=>"http://doi.org/10.3389/fendo.2012.00005",
                                              "obj_id"=>work.pid,
                                              "relation_type_id"=>"cites",
                                              "provenance_url"=>"http://www.ncbi.nlm.nih.gov/sites/entrez?db=pubmed&cmd=link&LinkName=pubmed_pmc_refs&from_uid=17183631",
                                              "source_id"=>"pub_med")

      expect(response.first[:subj]).to eq("pid"=>"http://doi.org/10.3389/fendo.2012.00005",
                                          "issued"=>"2012",
                                          "author"=>[{"family"=>"Morrison", "given"=>"Shaun F."},
                                                     {"family"=>"Madden", "given"=>"Christopher J."},
                                                     {"family"=>"Tupone", "given"=>"Domenico"}],
                                          "container-title"=>"Frontiers in Endocrinology",
                                          "volume"=>"3",
                                          "issue"=>nil,
                                          "page"=>nil,
                                          "title"=>"Central Control of Brown Adipose Tissue Thermogenesis",
                                          "DOI"=>"10.3389/fendo.2012.00005",
                                          "PMID"=>"22389645",
                                          "PMCID"=>"3292175",
                                          "type"=>"article-journal",
                                          "tracked"=>false,
                                          "publisher_id"=>"1965",
                                          "registration_agency_id"=>"crossref")
    end

    it "should report if there is a single event returned by the PubMed API" do
      body = File.read(fixture_path + 'pub_med_one.xml')
      result = Hash.from_xml(body)
      result.extend Hashie::Extensions::DeepFetch
      response = subject.parse_data(result, work_id: work.id)

      expect(response.length).to eq(1)
      expect(response.first[:relation]).to eq("subj_id"=>"http://doi.org/10.3389/fendo.2012.00005",
                                              "obj_id"=>work.pid,
                                              "relation_type_id"=>"cites",
                                              "provenance_url"=>"http://www.ncbi.nlm.nih.gov/sites/entrez?db=pubmed&cmd=link&LinkName=pubmed_pmc_refs&from_uid=17183631",
                                              "source_id"=>"pub_med")

      expect(response.first[:subj]).to eq("pid"=>"http://doi.org/10.3389/fendo.2012.00005",
                                          "issued"=>"2012",
                                          "author"=>[{"family"=>"Morrison", "given"=>"Shaun F."},
                                                     {"family"=>"Madden", "given"=>"Christopher J."},
                                                     {"family"=>"Tupone", "given"=>"Domenico"}],
                                          "container-title"=>"Frontiers in Endocrinology",
                                          "volume"=>"3",
                                          "issue"=>nil,
                                          "page"=>nil,
                                          "title"=>"Central Control of Brown Adipose Tissue Thermogenesis",
                                          "DOI"=>"10.3389/fendo.2012.00005",
                                          "PMID"=>"22389645",
                                          "PMCID"=>"3292175",
                                          "type"=>"article-journal",
                                          "tracked"=>false,
                                          "publisher_id"=>"1965",
                                          "registration_agency_id"=>"crossref")
    end

    it "should catch timeout errors with the PubMed API" do
      work = FactoryGirl.create(:work, :doi => "10.2307/683422")
      result = { error: "the server responded with status 408 for http://www.ncbi.nlm.nih.gov/pmc/utils/entrez2pmcciting.cgi?view=xml&id=17183631", status: 408 }
      response = subject.parse_data(result, work_id: work.id)
      expect(response).to eq([result])
    end
  end
end
