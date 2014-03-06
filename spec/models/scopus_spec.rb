# encoding: UTF-8

require 'spec_helper'

describe Scopus do
  let(:scopus) { FactoryGirl.create(:scopus) }

  it "should report that there are no events if the DOI is missing" do
    article = FactoryGirl.build(:article, :doi => "")
    scopus.get_data(article).should eq({ :events => [], :event_count => nil })
  end

  context "use the Scopus API" do
    context "use article without events" do
      it "should report if there are no events and event_count returned by the Scopus API" do
        article = FactoryGirl.build(:article, :doi => "10.1371/journal.pone.000001")
        stub = stub_request(:get, scopus.get_query_url(article)).with(:headers => { 'Accept'=>'application/json', 'User-Agent'=>'Article-Level Metrics - http://#{CONFIG[:hostname]}', 'X-ELS-APIKEY' => scopus.api_key, 'X-ELS-INSTTOKEN' => scopus.insttoken }).to_return(:headers => { "Content-Type" => "application/json" }, :body => File.read(fixture_path + 'scopus_nil.json'), :status => 200)
        scopus.get_data(article).should eq({ :events=>[], :event_count=>0, :event_metrics=>{:pdf=>nil, :html=>nil, :shares=>nil, :groups=>nil, :comments=>nil, :likes=>nil, :citations=>0, :total=>0 }})
        stub.should have_been_requested
      end
    end

    context "use article with events" do
      let(:article) { FactoryGirl.build(:article, :doi => "10.1371/journal.pmed.0030442") }

      it "should report if there are events and event_count returned by the Scopus API" do
        body = File.read(fixture_path + 'scopus.json')
        events = JSON.parse(body)["search-results"]["entry"][0]
        stub = stub_request(:get, scopus.get_query_url(article)).with(:headers => { 'Accept'=>'application/json', 'User-Agent'=>'Article-Level Metrics - http://#{CONFIG[:hostname]}', 'X-ELS-APIKEY' => scopus.api_key, 'X-ELS-INSTTOKEN' => scopus.insttoken }).to_return(:headers => { "Content-Type" => "application/json" }, :body => body, :status => 200)
        scopus.get_data(article).should eq({ :events => events, :event_count => 1814, :events_url=>"http://www.scopus.com/inward/citedby.url?partnerID=HzOxMe3b&scp=33845338724", :event_metrics => {:pdf=>nil, :html=>nil, :shares=>nil, :groups=>nil, :comments=>nil, :likes=>nil, :citations=>1814, :total=>1814} })
        stub.should have_been_requested
      end

      it "should catch errors with the Scopus API" do
        stub = stub_request(:get, scopus.get_query_url(article)).to_return(:status => [408])
        scopus.get_data(article, options = { :source_id => scopus.id }).should be_nil
        stub.should have_been_requested
        Alert.count.should == 1
        alert = Alert.first
        alert.class_name.should eq("Net::HTTPRequestTimeOut")
        alert.status.should == 408
        alert.source_id.should == scopus.id
      end
    end
  end
end
