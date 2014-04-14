# encoding: UTF-8

require 'spec_helper'

describe PmcEurope do
  subject { FactoryGirl.create(:pmc_europe) }

  it "should report that there are no events if the pmid is missing" do
    article = FactoryGirl.build(:article, :pmid => "")
    subject.get_data(article).should eq(events: [], event_count: nil)
  end

  context "use the PMC Europe API" do
    context "use article without events" do
      it "should report if there are no events and event_count returned by the PMC Europe API" do
        article = FactoryGirl.build(:article, :pmid => "20098740")
        stub = stub_request(:get, subject.get_query_url(article)).to_return(:headers => { "Content-Type" => "application/json" }, :body => File.read(fixture_path + 'pmc_europe_nil.json'), :status => 200)
        subject.get_data(article).should eq(event_count: 0, events_url: "http://europepmc.org/abstract/MED/#{article.pmid}#fragment-related-citations", event_metrics: { pdf: nil, html: nil, shares: nil, groups: nil, comments: nil, likes: nil, citations: 0, total: 0 })
        stub.should have_been_requested
      end
    end

    context "use article with events" do
      let(:article) { FactoryGirl.build(:article, :pmid => "17183631") }

      it "should report if there are events and event_count returned by the PMC Europe API" do
        stub = stub_request(:get, subject.get_query_url(article)).to_return(:headers => { "Content-Type" => "application/json" }, :body => File.read(fixture_path + 'pmc_europe.json'), :status => 200)
        subject.get_data(article).should eq(event_count: 23, events_url: "http://europepmc.org/abstract/MED/#{article.pmid}#fragment-related-citations", event_metrics: {pdf: nil, html: nil, shares: nil, groups: nil, comments: nil, likes: nil, citations: 23, total: 23 })
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
