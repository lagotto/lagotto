require 'rails_helper'

describe PubMed, type: :model, vcr: true do
  subject { FactoryGirl.create(:pub_med) }

  let(:work) { FactoryGirl.create(:work, :doi => "10.1371/journal.pone.0000001", :pmid => "17183631", :pmcid => "1762328") }

  context "get_data" do
    it "should report that there are no events if the doi, pmid and pmcid are missing" do
      work = FactoryGirl.create(:work, doi: nil, pmid: nil, pmcid: nil)
      expect(subject.get_data(work)).to eq({})
    end

    it "should report if there are no events and event_count returned by the PubMed API" do
      work = FactoryGirl.create(:work, :doi => "10.1371/journal.pone.0008776", :pmid => "1897483599", :pmcid => "2808249")
      response = subject.get_data(work)
      expect(response["PubMedToPMCcitingformSET"]["REFORM"]["PMCID"]).to be_nil
    end

    it "should report if there are events and event_count returned by the PubMed API" do
      response = subject.get_data(work)
      expect(response["PubMedToPMCcitingformSET"]["REFORM"]["PMCID"].length).to eq(17)
      expect(response["PubMedToPMCcitingformSET"]["REFORM"]["PMCID"].first).to eq("2464333")
    end

    it "should catch errors with the PubMed API" do
      stub = stub_request(:get, subject.get_query_url(work)).to_return(:status => [408])
      response = subject.get_data(work, options = { :agent_id => subject.id })
      expect(response).to eq(error: "the server responded with status 408 for http://www.pubmedcentral.nih.gov/utils/entrez2pmcciting.cgi?view=xml&id=#{work.pmid}", :status=>408)
      expect(stub).to have_been_requested
      expect(Notification.count).to eq(1)
      notification = Notification.first
      expect(notification.class_name).to eq("Net::HTTPRequestTimeOut")
      expect(notification.status).to eq(408)
      expect(notification.agent_id).to eq(subject.id)
    end
  end

  context "parse_data" do
    it "should report that there are no events if the pmid is missing" do
      work = FactoryGirl.create(:work, :pmid => "")
      result = {}
      result.extend Hashie::Extensions::DeepFetch
      expect(subject.parse_data(result, work)).to eq(works: [], events: [{ source_id: "pub_med", work_id: work.pid, total: 0, extra: [], days: [], months: [] }])
    end

    it "should report if there are no events and event_count returned by the PubMed API" do
      work = FactoryGirl.create(:work, :doi => "10.1371/journal.pone.0008776", :pmid => "1897483599", :pmcid => "2808249")
      body = File.read(fixture_path + 'pub_med_nil.xml')
      result = Hash.from_xml(body)
      result.extend Hashie::Extensions::DeepFetch
      response = subject.parse_data(result, work)
      expect(response).to eq(works: [], events: [{ source_id: "pub_med", work_id: work.pid, total: 0, extra: [], days: [], months: [] }])
    end

    it "should report if there are events and event_count returned by the PubMed API" do
      body = File.read(fixture_path + 'pub_med.xml')
      result = Hash.from_xml(body)
      result.extend Hashie::Extensions::DeepFetch
      response = subject.parse_data(result, work)

      event = response[:events].first
      expect(event[:source_id]).to eq("pub_med")
      expect(event[:work_id]).to eq(work.pid)
      expect(event[:total]).to eq(13)
      expect(event[:events_url]).to eq("http://www.ncbi.nlm.nih.gov/sites/entrez?db=pubmed&cmd=link&LinkName=pubmed_pmc_refs&from_uid=17183631")

      expect(response[:works].length).to eq(13)
      related_work = response[:works].first
      expect(related_work["DOI"]).to eq("10.3389/fendo.2012.00005")
      expect(related_work["PMID"]).to eq("22389645")
      expect(related_work["PMCID"]).to eq("3292175")
      expect(related_work['author']).to eq([{"affiliation"=>[], "family"=>"Morrison", "given"=>"Shaun F."}, {"affiliation"=>[], "family"=>"Madden", "given"=>"Christopher J."}, {"affiliation"=>[], "family"=>"Tupone", "given"=>"Domenico"}])
      expect(related_work['title']).to eq("Central Control of Brown Adipose Tissue Thermogenesis")
      expect(related_work['container-title']).to eq("Front. Endocrin.")
      expect(related_work['issued']).to eq("date-parts"=>[[2012]])
      expect(related_work['volume']).to eq("3")
      expect(related_work['issue']).to be_nil
      expect(related_work['page']).to be_nil
      expect(related_work['type']).to eq("article-journal")
      expect(related_work['related_works']).to eq([{"related_work"=> work.pid, "source"=>"pub_med", "relation_type"=>"cites"}])

      extra = event[:extra].first
      expect(extra[:event_url]).to eq("http://www.pubmedcentral.nih.gov/articlerender.fcgi?artid=" + extra[:event])
    end

    it "should report if there is a single event returned by the PubMed API" do
      body = File.read(fixture_path + 'pub_med_one.xml')
      result = Hash.from_xml(body)
      result.extend Hashie::Extensions::DeepFetch
      response = subject.parse_data(result, work)

      event = response[:events].first
      expect(event[:source_id]).to eq("pub_med")
      expect(event[:work_id]).to eq(work.pid)
      expect(event[:total]).to eq(1)
      expect(event[:events_url]).to eq("http://www.ncbi.nlm.nih.gov/sites/entrez?db=pubmed&cmd=link&LinkName=pubmed_pmc_refs&from_uid=17183631")

      expect(response[:works].length).to eq(1)
      related_work = response[:works].first
      expect(related_work["DOI"]).to eq("10.3389/fendo.2012.00005")
      expect(related_work["PMID"]).to eq("22389645")
      expect(related_work["PMCID"]).to eq("3292175")
      expect(related_work['author']).to eq([{"affiliation"=>[], "family"=>"Morrison", "given"=>"Shaun F."}, {"affiliation"=>[], "family"=>"Madden", "given"=>"Christopher J."}, {"affiliation"=>[], "family"=>"Tupone", "given"=>"Domenico"}])
      expect(related_work['title']).to eq("Central Control of Brown Adipose Tissue Thermogenesis")
      expect(related_work['container-title']).to eq("Front. Endocrin.")
      expect(related_work['issued']).to eq("date-parts"=>[[2012]])
      expect(related_work['volume']).to eq("3")
      expect(related_work['issue']).to be_nil
      expect(related_work['page']).to be_nil
      expect(related_work['type']).to eq("article-journal")
      expect(related_work['related_works']).to eq([{"related_work"=> work.pid, "source"=>"pub_med", "relation_type"=>"cites"}])
    end

    it "should catch timeout errors with the PubMed API" do
      work = FactoryGirl.create(:work, :doi => "10.2307/683422")
      result = { error: "the server responded with status 408 for http://www.pubmedcentral.nih.gov/utils/entrez2pmcciting.cgi?view=xml&id=#{work.pmid}", status: 408 }
      response = subject.parse_data(result, work)
      expect(response).to eq(result)
    end
  end
end
