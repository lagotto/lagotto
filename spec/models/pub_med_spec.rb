require 'rails_helper'

describe PubMed, :type => :model do
  subject { FactoryGirl.create(:pub_med) }

  let(:article) { FactoryGirl.create(:article, :doi => "10.1371/journal.pone.0000001", :pmid => "17183631", :pmcid => "1762328") }

  context "get_data" do
    it "should report that there are no events if the pmid is missing" do
      article = FactoryGirl.build(:article, :pmid => "")
      pubmed_url = "http://www.pubmedcentral.nih.gov/utils/idconv/v1.0/?ids=#{article.doi_escaped}&idtype=doi&format=json"
      stub = stub_request(:get, pubmed_url).to_return(:body => File.read(fixture_path + 'persistent_identifiers_nil.json'))
      expect(subject.get_data(article)).to eq({})
    end

    it "should report if there are no events and event_count returned by the PubMed API" do
      article = FactoryGirl.create(:article, :doi => "10.1371/journal.pone.0008776", :pmid => "1897483599", :pmcid => "2808249")
      body = File.read(fixture_path + 'pub_med_nil.xml')
      stub = stub_request(:get, subject.get_query_url(article)).to_return(:body => body)
      response = subject.get_data(article)
      expect(response).to eq(Hash.from_xml(body))
      expect(stub).to have_been_requested
    end

    it "should report if there are events and event_count returned by the PubMed API" do
      body = File.read(fixture_path + 'pub_med.xml')
      stub = stub_request(:get, subject.get_query_url(article)).to_return(:body => body)
      response = subject.get_data(article)
      expect(response).to eq(Hash.from_xml(body))
      expect(stub).to have_been_requested
    end

    it "should catch errors with the PubMed API" do
      stub = stub_request(:get, subject.get_query_url(article)).to_return(:status => [408])
      response = subject.get_data(article, options = { :source_id => subject.id })
      expect(response).to eq(error: "the server responded with status 408 for http://www.pubmedcentral.nih.gov/utils/entrez2pmcciting.cgi?view=xml&id=#{article.pmid}", :status=>408)
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
      article = FactoryGirl.build(:article, :pmid => "")
      result = {}
      result.extend Hashie::Extensions::DeepFetch
      expect(subject.parse_data(result, article)).to eq(:events=>[], :events_by_day=>[], :events_by_month=>[], :events_url=>nil, :event_count=>0, :event_metrics=>{:pdf=>nil, :html=>nil, :shares=>nil, :groups=>nil, :comments=>nil, :likes=>nil, :citations=>0, :total=>0})
    end

    it "should report if there are no events and event_count returned by the PubMed API" do
      article = FactoryGirl.create(:article, :doi => "10.1371/journal.pone.0008776", :pmid => "1897483599", :pmcid => "2808249")
      body = File.read(fixture_path + 'pub_med_nil.xml')
      result = Hash.from_xml(body)
      result.extend Hashie::Extensions::DeepFetch
      response = subject.parse_data(result, article)
      expect(response).to eq(events: [], event_count: 0, :events_by_day=>[], :events_by_month=>[], events_url: "http://www.ncbi.nlm.nih.gov/sites/entrez?db=pubmed&cmd=link&LinkName=pubmed_pmc_refs&from_uid=1897483599", event_metrics: { pdf: nil, html: nil, shares: nil, groups: nil, comments: nil, likes: nil, citations: 0, total: 0})
    end

    it "should report if there are events and event_count returned by the PubMed API" do
      body = File.read(fixture_path + 'pub_med.xml')
      result = Hash.from_xml(body)
      result.extend Hashie::Extensions::DeepFetch
      response = subject.parse_data(result, article)
      expect(response[:events].length).to eq(13)
      expect(response[:event_count]).to eq(13)
      event = response[:events].first
      expect(event[:event_url]).to eq("http://www.pubmedcentral.nih.gov/articlerender.fcgi?artid=" + event[:event])
    end

    it "should report if there is a single event returned by the PubMed API" do
      body = File.read(fixture_path + 'pub_med_one.xml')
      result = Hash.from_xml(body)
      result.extend Hashie::Extensions::DeepFetch
      response = subject.parse_data(result, article)
      expect(response[:events].length).to eq(1)
      expect(response[:event_count]).to eq(1)
      event = response[:events].first
      expect(event[:event_url]).to eq("http://www.pubmedcentral.nih.gov/articlerender.fcgi?artid=" + event[:event])
    end

    it "should catch timeout errors with the PubMed API" do
      article = FactoryGirl.create(:article, :doi => "10.2307/683422")
      result = { error: "the server responded with status 408 for http://www.pubmedcentral.nih.gov/utils/entrez2pmcciting.cgi?view=xml&id=#{article.pmid}", status: 408 }
      response = subject.parse_data(result, article)
      expect(response).to eq(result)
    end
  end
end
