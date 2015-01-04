require 'rails_helper'

describe PubMed, type: :model, vcr: true do
  subject { FactoryGirl.create(:pub_med) }

  let(:work) { FactoryGirl.create(:work, :doi => "10.1371/journal.pone.0000001", :pmid => "17183631", :pmcid => "1762328") }

  context "get_data" do
    it "should report that there are no events if the doi and pmid are missing" do
      work = FactoryGirl.build(:work, doi: nil, pmid: nil)
      expect(subject.get_data(work)).to eq({})
    end

    it "should report if there are no events and event_count returned by the PubMed API" do
      work = FactoryGirl.create(:work, :doi => "10.1371/journal.pone.0008776", :pmid => "1897483599", :pmcid => "2808249")
      response = subject.get_data(work)
      expect(response["PubMedToPMCcitingformSET"]["REFORM"]["PMCID"]).to be_nil
    end

    it "should report if there are events and event_count returned by the PubMed API" do
      response = subject.get_data(work)
      expect(response["PubMedToPMCcitingformSET"]["REFORM"]["PMCID"].length).to eq(16)
      expect(response["PubMedToPMCcitingformSET"]["REFORM"]["PMCID"].first).to eq("1976277")
    end

    it "should catch errors with the PubMed API" do
      stub = stub_request(:get, subject.get_query_url(work)).to_return(:status => [408])
      response = subject.get_data(work, options = { :source_id => subject.id })
      expect(response).to eq(error: "the server responded with status 408 for http://www.pubmedcentral.nih.gov/utils/entrez2pmcciting.cgi?view=xml&id=#{work.pmid}", :status=>408)
      expect(stub).to have_been_requested
      expect(Alert.count).to eq(1)
      alert = Alert.first
      expect(alert.class_name).to eq("Net::HTTPRequestTimeOut")
      expect(alert.status).to eq(408)
      expect(alert.source_id).to eq(subject.id)
    end
  end

  context "parse_data" do
    it "should report that there are no events if the pmid is missing" do
      work = FactoryGirl.build(:work, :pmid => "")
      result = {}
      result.extend Hashie::Extensions::DeepFetch
      expect(subject.parse_data(result, work)).to eq(:events=>[], :events_by_day=>[], :events_by_month=>[], :events_url=>nil, :event_count=>0, :event_metrics=>{:pdf=>nil, :html=>nil, :shares=>nil, :groups=>nil, :comments=>nil, :likes=>nil, :citations=>0, :total=>0})
    end

    it "should report if there are no events and event_count returned by the PubMed API" do
      work = FactoryGirl.create(:work, :doi => "10.1371/journal.pone.0008776", :pmid => "1897483599", :pmcid => "2808249")
      body = File.read(fixture_path + 'pub_med_nil.xml')
      result = Hash.from_xml(body)
      result.extend Hashie::Extensions::DeepFetch
      response = subject.parse_data(result, work)
      expect(response).to eq(events: [], event_count: 0, :events_by_day=>[], :events_by_month=>[], events_url: nil, event_metrics: { pdf: nil, html: nil, shares: nil, groups: nil, comments: nil, likes: nil, citations: 0, total: 0})
    end

    it "should report if there are events and event_count returned by the PubMed API" do
      body = File.read(fixture_path + 'pub_med.xml')
      result = Hash.from_xml(body)
      result.extend Hashie::Extensions::DeepFetch
      response = subject.parse_data(result, work)
      expect(response[:events].length).to eq(13)
      expect(response[:event_count]).to eq(13)
      event = response[:events].first
      expect(event[:event_url]).to eq("http://www.pubmedcentral.nih.gov/articlerender.fcgi?artid=" + event[:event])
    end

    it "should report if there is a single event returned by the PubMed API" do
      body = File.read(fixture_path + 'pub_med_one.xml')
      result = Hash.from_xml(body)
      result.extend Hashie::Extensions::DeepFetch
      response = subject.parse_data(result, work)
      expect(response[:events].length).to eq(1)
      expect(response[:event_count]).to eq(1)
      event = response[:events].first
      expect(event[:event_url]).to eq("http://www.pubmedcentral.nih.gov/articlerender.fcgi?artid=" + event[:event])
    end

    it "should catch timeout errors with the PubMed API" do
      work = FactoryGirl.create(:work, :doi => "10.2307/683422")
      result = { error: "the server responded with status 408 for http://www.pubmedcentral.nih.gov/utils/entrez2pmcciting.cgi?view=xml&id=#{work.pmid}", status: 408 }
      response = subject.parse_data(result, work)
      expect(response).to eq(result)
    end
  end
end
