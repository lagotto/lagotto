require 'spec_helper'

describe Pmc do
  let(:pmc) { FactoryGirl.create(:pmc) }

  it "should report that there are no events if the doi is missing" do
    article = FactoryGirl.build(:article, :doi => "")
    pmc.get_data(article).should eq({ :events => [], :event_count => nil })
  end

  it "should report that there are no events if article was published on the same day" do
    article = FactoryGirl.build(:article, :published_on => Time.zone.today)
    pmc.get_data(article).should eq({ :events => [], :event_count => nil })
  end

  context "save and parse PMC data" do
    let(:month) { 1.month.ago.month }
    let(:year) { 1.month.ago.year }
    let(:journal) { "plosbiol" }

    it "should fetch and save PMC data" do
      stub = stub_request(:get, pmc.get_feed_url(month, year, journal)).to_return(:headers => { "Content-Type" => "application/xml" }, :body => File.read(fixture_path + 'pmc.xml'), :status => 200)
      pmc.get_feed(month, year).should be_empty
      file = "#{Rails.root}/data/pmcstat_#{journal}_#{month}_#{year}.xml"
      File.exist?(file).should be_true
      stub.should have_been_requested
      Alert.count.should == 0
    end
  end

  context "save and parse PMC data" do
    let(:month) { 1.month.ago.month }
    let(:year) { 1.month.ago.year }
    let(:journal) { "plosbiol" }

    before(:each) do
      pmc.put_alm_data(pmc.url)
    end

    after(:each) do
      pmc.delete_alm_data(pmc.url)
    end

    it "should parse PMC data" do
      stub = stub_request(:get, pmc.get_feed_url(month, year, journal)).to_return(:headers => { "Content-Type" => "application/xml" }, :body => File.read(fixture_path + 'pmc.xml'), :status => 200)
      pmc.get_feed(month, year).should be_empty
      pmc.parse_feed(month, year).should be_empty
      stub.should have_been_requested
      Alert.count.should == 0
    end
  end

  context "use the PMC API" do

    before(:each) do
      pmc.put_alm_data(pmc.url)
    end

    after(:each) do
      pmc.delete_alm_data(pmc.url)
    end

    it "should report if there are no events and event_count returned by the PMC API" do
      article = FactoryGirl.build(:article, :doi => "10.1371/journal.pone.0044294")
      body = File.read(fixture_path + 'pmc_nil.json')
      stub = stub_request(:get, pmc.get_query_url(article)).to_return(:headers => { "Content-Type" => "application/json" }, :body => body, :status => 200)
      pmc.get_data(article).should eq({ :events => [{"unique_ip"=>"0", "full_text"=>"0", "pdf"=>"0", "abstract"=>"0", "scanned_summary"=>"0", "scanned_page_browse"=>"0", "figure"=>"0", "supp_data"=>"0", "cited_by"=>"0", "year"=>2013, "month"=>10}], :event_count => 0, :event_metrics => { :pdf=>0, :html=>0, :shares=>nil, :groups=>nil, :comments=>nil, :likes=>nil, :citations=>nil, :total=>0 }})
      stub.should have_been_requested
    end

    it "should report if there are events and event_count returned by the PMC API" do
      article = FactoryGirl.build(:article, :doi => "10.1371/journal.pbio.1001420")
      body = File.read(fixture_path + 'pmc.json')
      stub = stub_request(:get, pmc.get_query_url(article)).to_return(:headers => { "Content-Type" => "application/json" }, :body => body, :status => 200)
      response = pmc.get_data(article)
      response[:events].length.should eq(2)
      response[:event_count].should eq(13)
      response[:event_metrics].should eq({ :pdf=>4, :html=>9, :shares=>nil, :groups=>nil, :comments=>nil, :likes=>nil, :citations=>nil, :total=>13 })
      stub.should have_been_requested
    end

    it "should catch errors with the PMC API" do
      article = FactoryGirl.build(:article, :doi => "10.1371/journal.pone.0000001")
      stub = stub_request(:get, pmc.get_query_url(article)).to_return(:status => [408])
      pmc.get_data(article, options = { :source_id => pmc.id }).should be_nil
      stub.should have_been_requested
      Alert.count.should == 1
      alert = Alert.first
      alert.class_name.should eq("Net::HTTPRequestTimeOut")
      alert.status.should == 408
      alert.source_id.should == pmc.id
    end
  end
end