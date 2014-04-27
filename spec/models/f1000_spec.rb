require 'spec_helper'

describe F1000 do
  subject { FactoryGirl.create(:f1000) }

  it "should report that there are no events if the doi is missing" do
    article = FactoryGirl.build(:article, :doi => "")
    subject.parse_data(article).should eq(events: [], event_count: nil)
  end

  context "save f1000 data" do
    it "should fetch and save f1000 data" do
      stub = stub_request(:get, subject.get_feed_url).to_return(:headers => { "Content-Type" => "application/xml" }, :body => File.read(fixture_path + 'f1000.xml'), :status => 200)
      #subject.get_feed.should be_true
      #file = "#{Rails.root}/data/#{subject.filename}.xml"
      #File.exist?(file).should be_true
      stub.should have_been_requested
      Alert.count.should == 0
    end
  end

  context "parse f1000 data" do
    before(:each) do
      subject.put_alm_data(subject.url)
    end

    after(:each) do
      subject.delete_alm_data(subject.url)
    end

    it "should parse f1000 data" do
      stub = stub_request(:get, subject.get_feed_url).to_return(:headers => { "Content-Type" => "application/xml" }, :body => File.read(fixture_path + 'f1000.xml'), :status => 200)
      subject.get_feed.should be_true
      subject.parse_feed.should be_true
      stub.should have_been_requested
      Alert.count.should == 0
    end
  end

  context "use the f1000 internal database" do
    before(:each) do
      subject.put_alm_data(subject.url)
    end

    after(:each) do
      subject.delete_alm_data(subject.url)
    end

    it "should report if there are no events and event_count returned by f1000" do
      article = FactoryGirl.create(:article, :doi => "10.1371/journal.pone.0044294")
      body = File.read(fixture_path + 'f1000_nil.json')
      stub = stub_request(:get, subject.get_query_url(article)).to_return(:headers => { "Content-Type" => "application/json" }, :body => body, :status => 200)
      subject.parse_data(article).should eq(events: [{ "unique-ip" => "0", "full-text" => "0", "pdf" => "0", "abstract" => "0", "scanned-summary" => "0", "scanned-page-browse" => "0", "figure" => "0", "supp-data" => "0", "cited-by" => "0", "year" => "2013", "month" => "10" }], event_count: 0, event_metrics: { pdf: 0, html: 0, shares: nil, groups: nil, comments: nil, likes: nil, citations: nil, total: 0 })
      stub.should have_been_requested
    end

    it "should report if there are events and event_count returned by f1000" do
      article = FactoryGirl.create(:article, :doi => "10.1371/journal.pbio.1001420")
      body = File.read(fixture_path + 'f1000.json')
      stub = stub_request(:get, subject.get_query_url(article)).to_return(:headers => { "Content-Type" => "application/json" }, :body => body, :status => 200)
      response = subject.parse_data(article)
      response[:event_count].should eq(2)
      response[:events_url].should eq("http://f1000.com/prime/13421")
      response[:events]["Classifications"].should eq("NEW_FINDING")
      stub.should have_been_requested
    end

    it "should catch errors with f1000" do
      article = FactoryGirl.create(:article, :doi => "10.1371/journal.pone.0000001")
      stub = stub_request(:get, subject.get_query_url(article)).to_return(:status => [408])
      subject.parse_data(article, options = { :source_id => subject.id }).should eq({:events=>[], :event_count=>0})
      stub.should have_been_requested
      Alert.count.should == 1
      alert = Alert.first
      alert.class_name.should eq("Net::HTTPRequestTimeOut")
      alert.status.should == 408
      alert.source_id.should == subject.id
    end
  end
end
