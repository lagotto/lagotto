# encoding: UTF-8

require 'spec_helper'

describe PmcEuropeData do
  subject { FactoryGirl.create(:pmc_europe_data) }

  let(:article) { FactoryGirl.build(:article, :pmid => "14624247") }

  context "get_data" do
    it "should report that there are no events if the pmid is missing" do
      article = FactoryGirl.build(:article, :pmid => "")
      pubmed_url = "http://www.pubmedcentral.nih.gov/utils/idconv/v1.0/?ids=#{article.doi_escaped}&idtype=doi&format=json"
      stub = stub_request(:get, pubmed_url).to_return(:body => File.read(fixture_path + 'persistent_identifiers_nil.json'))
      subject.get_data(article).should eq({})
    end

    it "should report if there are no events and event_count returned by the PMC Europe API" do
      article = FactoryGirl.build(:article, :pmid => "20098740")
      body = File.read(fixture_path + 'pmc_europe_data_nil.json')
      stub = stub_request(:get, subject.get_query_url(article)).to_return(:body => body)
      response = subject.get_data(article)
      response.should eq(JSON.parse(body))
      stub.should have_been_requested
    end

    it "should report if there are events and event_count returned by the PMC Europe API" do
      body = File.read(fixture_path + 'pmc_europe_data.json')
      stub = stub_request(:get, subject.get_query_url(article)).to_return(:body => body)
      response = subject.get_data(article)
      response.should eq(JSON.parse(body))
      stub.should have_been_requested
    end

    it "should catch errors with the PMC Europe API" do
      stub = stub_request(:get, subject.get_query_url(article)).to_return(:status => [408])
      response = subject.get_data(article, source_id: subject.id)
      response.should eq(error: "the server responded with status 408 for http://www.ebi.ac.uk/europepmc/webservices/rest/MED/#{article.pmid}/databaseLinks//1/json")
      stub.should have_been_requested
      Alert.count.should == 1
      alert = Alert.first
      alert.class_name.should eq("Net::HTTPRequestTimeOut")
      alert.status.should == 408
      alert.source_id.should == subject.id
    end
  end

  context "get_data via accession_id" do
    it "should report that there are no events if the doi is missing" do
      subject.url = "http://www.ebi.ac.uk/europepmc/webservices/rest/search/query=ACCESSION_ID:%{doi}"
      article = FactoryGirl.build(:article, :doi => "")
      subject.get_data(article).should eq({})
    end

    it "should report if there are no events and event_count returned by the PMC Europe API" do
      subject.url = "http://www.ebi.ac.uk/europepmc/webservices/rest/search/query=ACCESSION_ID:%{doi}"
      article = FactoryGirl.build(:article, :pmid => "20098740")
      body = File.read(fixture_path + 'pmc_europe_data_nil.xml')
      stub = stub_request(:get, subject.get_query_url(article)).to_return(:body => body)
      response = subject.get_data(article)
      response.should eq(Hash.from_xml(body))
      stub.should have_been_requested
    end

    it "should report if there are events and event_count returned by the PMC Europe API" do
      subject.url = "http://www.ebi.ac.uk/europepmc/webservices/rest/search/query=ACCESSION_ID:%{doi}"
      body = File.read(fixture_path + 'pmc_europe_data.xml')
      stub = stub_request(:get, subject.get_query_url(article)).to_return(:body => body)
      response = subject.get_data(article)
      response.should eq(Hash.from_xml(body))
      stub.should have_been_requested
    end

    it "should catch errors with the PMC Europe API" do
      subject.url = "http://www.ebi.ac.uk/europepmc/webservices/rest/search/query=ACCESSION_ID:%{doi}"
      stub = stub_request(:get, subject.get_query_url(article)).to_return(:status => [408])
      response = subject.get_data(article, source_id: subject.id)
      response.should eq(error: "the server responded with status 408 for http://www.ebi.ac.uk/europepmc/webservices/rest/search/query=ACCESSION_ID:#{article.doi}")
      stub.should have_been_requested
      Alert.count.should == 1
      alert = Alert.first
      alert.class_name.should eq("Net::HTTPRequestTimeOut")
      alert.status.should == 408
      alert.source_id.should == subject.id
    end
  end

  context "parse_data" do
    it "should report that there are no events if the pmid is missing" do
      article = FactoryGirl.build(:article, :pmid => "")
      result = {}
      subject.parse_data(result, article).should eq(:events=>[], :events_by_day=>[], :events_by_month=>[], :events_url=>nil, :event_count=>0, :event_metrics=>{:pdf=>nil, :html=>nil, :shares=>nil, :groups=>nil, :comments=>nil, :likes=>nil, :citations=>0, :total=>0})
    end

    it "should report if there are no events and event_count returned by the PMC Europe API" do
      article = FactoryGirl.build(:article, :pmid => "20098740")
      body = File.read(fixture_path + 'pmc_europe_data_nil.json')
      result = JSON.parse(body)
      response = subject.parse_data(result, article)
      response.should eq(events: [], :events_by_day=>[], :events_by_month=>[], event_count: 0, events_url: "http://europepmc.org/abstract/MED/#{article.pmid}#fragment-related-bioentities", event_metrics: { pdf: nil, html: nil, shares: nil, groups: nil, comments: nil, likes: nil, citations: 0, total: 0 })
    end

    it "should report if there are events and event_count returned by the PMC Europe API" do
      body = File.read(fixture_path + 'pmc_europe_data.json')
      result = JSON.parse(body)
      response = subject.parse_data(result, article)
      response.should eq(events: { "EMBL" => 10, "UNIPROT" => 21700 }, :events_by_day=>[], :events_by_month=>[], event_count: 21710, events_url: "http://europepmc.org/abstract/MED/#{article.pmid}#fragment-related-bioentities", event_metrics: { pdf: nil, html: nil, shares: nil, groups: nil, comments: nil, likes: nil, citations: 21710, total: 21710 })
    end

    it "should catch timeout errors with the PMC Europe API" do
      article = FactoryGirl.create(:article, :doi => "10.2307/683422")
      result = { error: "the server responded with status 408 for http://www.ebi.ac.uk/europepmc/webservices/rest/MED/#{article.pmid}/databaseLinks//1/json" }
      response = subject.parse_data(result, article)
      response.should eq(result)
    end
  end

  context "parse_data via accession_id" do
    it "should report that there are no events if the doi is missing" do
      article = FactoryGirl.build(:article, :doi => "", :pmid => "")
      result = {}
      subject.parse_data(result, article).should eq(:events=>[], :events_by_day=>[], :events_by_month=>[], :events_url=>nil, :event_count=>0, :event_metrics=>{:pdf=>nil, :html=>nil, :shares=>nil, :groups=>nil, :comments=>nil, :likes=>nil, :citations=>0, :total=>0})
    end

    it "should report if there are no events and event_count returned by the PMC Europe API" do
      article = FactoryGirl.build(:article, :pmid => "")
      body = File.read(fixture_path + 'pmc_europe_data_nil.xml')
      result = Hash.from_xml(body)
      response = subject.parse_data(result, article)
      response.should eq(events: [], :events_by_day=>[], :events_by_month=>[], event_count: 0, events_url: nil, event_metrics: { pdf: nil, html: nil, shares: nil, groups: nil, comments: nil, likes: nil, citations: 0, total: 0 })
    end

    it "should report if there are events and event_count returned by the PMC Europe API" do
      article = FactoryGirl.build(:article, :pmid => "")
      body = File.read(fixture_path + 'pmc_europe_data.xml')
      result = Hash.from_xml(body)
      result.extend Hashie::Extensions::DeepFetch
      response = subject.parse_data(result, article)
      response[:event_count].should eq(1)
      response[:events_url].should be_nil

      event = response[:events].first

      event[:event_csl]['author'].should eq([{"family"=>"Ha.", "given"=>"Piwowar"}])
      event[:event_csl]['title'].should eq("Who shares? Who doesn't? Factors associated with openly archiving raw research data.")
      event[:event_csl]['container-title'].should eq("PLoS One")
      event[:event_csl]['issued'].should eq("date_parts"=>[2011])
      event[:event_csl]['type'].should eq("article-journal")

      event[:event_url].should eq("http://europepmc.org/abstract/MED/21765886")
    end
  end
end
