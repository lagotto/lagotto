# encoding: UTF-8

require 'spec_helper'

describe PmcEuropeData do
  subject { FactoryGirl.create(:pmc_europe_data) }

  it "should report that there are no events if the pmid is missing" do
    article = FactoryGirl.build(:article, :pmid => "")
    pubmed_url = "http://www.pubmedcentral.nih.gov/utils/idconv/v1.0/?ids=#{article.doi_escaped}&idtype=doi&format=json"
    stub = stub_request(:get, pubmed_url).to_return(:headers => { "Content-Type" => "application/json" }, :body => File.read(fixture_path + 'persistent_identifiers_nil.json'), :status => 200)
    subject.get_data(article).should eq(events: [], event_count: nil)
  end

  context "use the PMC Europe API" do
    context "use article without events" do
      it "should report if there are no events and event_count returned by the PMC Europe API" do
        article = FactoryGirl.build(:article, :pmid => "20098740")
        stub = stub_request(:get, subject.get_query_url(article)).to_return(:headers => { "Content-Type" => "application/json" }, :body => File.read(fixture_path + 'pmc_europe_data_nil.json'), :status => 200)
        subject.get_data(article).should eq(events: nil, event_count: 0, events_url: "http://europepmc.org/abstract/MED/#{article.pmid}#fragment-related-bioentities", event_metrics: { pdf: nil, html: nil, shares: nil, groups: nil, comments: nil, likes: nil, citations: 0, total: 0 })
        stub.should have_been_requested
      end
    end

    context "use article with events" do
      let(:article) { FactoryGirl.build(:article, :pmid => "14624247") }

      it "should report if there are events and event_count returned by the PMC Europe API" do
        stub = stub_request(:get, subject.get_query_url(article)).to_return(:headers => { "Content-Type" => "application/json" }, :body => File.read(fixture_path + 'pmc_europe_data.json'), :status => 200)
        subject.get_data(article).should eq(events: { "EMBL" => 10, "UNIPROT" => 21700 }, event_count: 21710, events_url: "http://europepmc.org/abstract/MED/#{article.pmid}#fragment-related-bioentities", event_metrics: { pdf: nil, html: nil, shares: nil, groups: nil, comments: nil, likes: nil, citations: 21710, total: 21710 })
        stub.should have_been_requested
      end

      it "should catch errors with the PMC Europe API" do
        stub = stub_request(:get, subject.get_query_url(article)).to_return(:status => [408])
        subject.get_data(article, source_id: subject.id).should be_nil
        stub.should have_been_requested
        Alert.count.should == 1
        alert = Alert.first
        alert.class_name.should eq("Net::HTTPRequestTimeOut")
        alert.status.should == 408
        alert.source_id.should == subject.id
      end
    end
  end
end
