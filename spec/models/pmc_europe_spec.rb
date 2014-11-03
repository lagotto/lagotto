require 'rails_helper'

describe PmcEurope, :type => :model do
  subject { FactoryGirl.create(:pmc_europe) }

  let(:article) { FactoryGirl.build(:article, :pmid => "17183631") }

  context "get_data" do
    it "should report that there are no events if the pmid is missing" do
      article = FactoryGirl.build(:article, :pmid => "")
      pubmed_url = "http://www.pubmedcentral.nih.gov/utils/idconv/v1.0/?ids=#{article.doi_escaped}&idtype=doi&format=json"
      stub = stub_request(:get, pubmed_url).to_return(:body => File.read(fixture_path + 'persistent_identifiers_nil.json'))
      expect(subject.get_data(article)).to eq({})
    end

    it "should report if there are no events and event_count returned by the PMC Europe API" do
      article = FactoryGirl.build(:article, :pmid => "20098740")
      body = File.read(fixture_path + 'pmc_europe_nil.json')
      stub = stub_request(:get, subject.get_query_url(article)).to_return(:body => body)
      response = subject.get_data(article)
      expect(response).to eq(JSON.parse(body))
      expect(stub).to have_been_requested
    end

    it "should report if there are events and event_count returned by the PMC Europe API" do
      body = File.read(fixture_path + 'pmc_europe.json')
      stub = stub_request(:get, subject.get_query_url(article)).to_return(:body => body)
      response = subject.get_data(article)
      expect(response).to eq(JSON.parse(body))
      expect(stub).to have_been_requested
    end

    it "should catch errors with the PMC Europe API" do
      stub = stub_request(:get, subject.get_query_url(article)).to_return(:status => [408])
      response = subject.get_data(article, source_id: subject.id)
      expect(response).to eq(error: "the server responded with status 408 for http://www.ebi.ac.uk/europepmc/webservices/rest/MED/#{article.pmid}/citations/1/json", :status=>408)
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
      expect(subject.parse_data(result, article)).to eq(:events=>[], :events_by_day=>[], :events_by_month=>[], :events_url=>nil, :event_count=>0, :event_metrics=>{:pdf=>nil, :html=>nil, :shares=>nil, :groups=>nil, :comments=>nil, :likes=>nil, :citations=>0, :total=>0})
    end

    it "should report if there are no events and event_count returned by the PMC Europe API" do
      article = FactoryGirl.build(:article, :pmid => "20098740")
      body = File.read(fixture_path + 'pmc_europe_nil.json')
      result = JSON.parse(body)
      expect(subject.parse_data(result, article)).to eq(events: [], :events_by_day=>[], :events_by_month=>[], event_count: 0, events_url: "http://europepmc.org/abstract/MED/#{article.pmid}#fragment-related-citations", event_metrics: { pdf: nil, html: nil, shares: nil, groups: nil, comments: nil, likes: nil, citations: 0, total: 0 })
    end

    it "should report if there are events and event_count returned by the PMC Europe API" do
      body = File.read(fixture_path + 'pmc_europe.json')
      result = JSON.parse(body)
      expect(subject.parse_data(result, article)).to eq(events: [], :events_by_day=>[], :events_by_month=>[], event_count: 23, events_url: "http://europepmc.org/abstract/MED/#{article.pmid}#fragment-related-citations", event_metrics: {pdf: nil, html: nil, shares: nil, groups: nil, comments: nil, likes: nil, citations: 23, total: 23 })
    end

    it "should catch timeout errors with the PMC Europe API" do
      article = FactoryGirl.create(:article, :doi => "10.2307/683422")
      result = { error: "the server responded with status 408 for http://www.ebi.ac.uk/europepmc/webservices/rest/MED/#{article.pmid}/citations/1/json", status: 408 }
      response = subject.parse_data(result, article)
      expect(response).to eq(result)
    end
  end
end
