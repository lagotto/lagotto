require 'spec_helper'

describe Datacite do
  let(:datacite) { FactoryGirl.create(:datacite) }

  it "should report that there are no events if the doi is missing" do
    article = FactoryGirl.build(:article, :doi => "")
    datacite.get_data(article).should eq({ :events => [], :event_count => nil })
  end

  context "use the Datacite API" do
    it "should report if there are no events and event_count returned by the Datacite API" do
      article = FactoryGirl.build(:article, :doi => "10.1371/journal.pone.0043007")
      stub = stub_request(:get, datacite.get_query_url(article)).to_return(:headers => { "Content-Type" => "application/json" }, :body => File.read(fixture_path + 'datacite_nil.json'), :status => 200)
      datacite.get_data(article).should eq({:events=>[], :events_url=>"http://search.datacite.org/ui?q=relatedIdentifier:#{article.doi_escaped}", :event_count=>0, :event_metrics=>{:pdf=>nil, :html=>nil, :shares=>nil, :groups=>nil, :comments=>nil, :likes=>nil, :citations=>0, :total=>0}})
      stub.should have_been_requested
    end

    it "should report if there are events and event_count returned by the Datacite API" do
      article = FactoryGirl.build(:article, :doi => "10.1371/journal.ppat.1000446")
      body = File.read(fixture_path + 'datacite.json')
      stub = stub_request(:get, datacite.get_query_url(article)).to_return(:headers => { "Content-Type" => "application/json" }, :body => body, :status => 200)
      response = datacite.get_data(article)
      response[:event_count].should == 1
      response[:events_url].should eq("http://search.datacite.org/ui?q=relatedIdentifier:#{article.doi_escaped}")
      event = response[:events].first
      event[:event_url].should eq("http://doi.org/10.5061/DRYAD.8515")
      stub.should have_been_requested
    end

    it "should catch timeout errors with the datacite API" do
      article = FactoryGirl.build(:article, :doi => "10.1371/journal.ppat.1000446")
      stub = stub_request(:get, datacite.get_query_url(article)).to_return(:status => [408])
      datacite.get_data(article, options = { :source_id => datacite.id }).should be_nil
      stub.should have_been_requested
      Alert.count.should == 1
      alert = Alert.first
      alert.class_name.should eq("Net::HTTPRequestTimeOut")
      alert.status.should == 408
      alert.source_id.should == datacite.id
    end
  end
end
