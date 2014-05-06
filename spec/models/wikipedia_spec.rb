require 'spec_helper'

describe Wikipedia do

  subject { FactoryGirl.create(:wikipedia) }

  let(:article) { FactoryGirl.build(:article, :doi => "10.1371/journal.pone.0044294") }

  context "get_data" do
    it "should report that there are no events if the doi is missing" do
      article = FactoryGirl.build(:article, :doi => nil)
      subject.get_data(article).should eq({})
    end

    it "should report if there are no events and event_count returned by the Wikipedia API" do
      body = File.read(fixture_path + 'wikipedia_nil.json')
      stub = stub_request(:get, /en.wikipedia.org/).to_return(:body => body)
      response = subject.get_data(article)
      response.should eq("en"=>0)
      stub.should have_been_requested
    end

    it "should report if there are events and event_count returned by the Wikipedia API" do
      article = FactoryGirl.build(:article, :doi => "10.1371/journal.pcbi.1002445")
      body = File.read(fixture_path + 'wikipedia.json')
      stub = stub_request(:get, /en.wikipedia.org/).to_return(:body => body)
      response = subject.get_data(article)
      response.should eq("en"=>12)
      stub.should have_been_requested
    end

    it "should catch errors with the Wikipedia API" do
      article = FactoryGirl.build(:article, :doi => "10.1371/journal.pone.0000001")
      stub = stub_request(:get, /en.wikipedia.org/).to_return(:body => File.read(fixture_path + 'wikipedia_error.json'), :status => [400])
      response = subject.get_data(article, options = { :source_id => subject.id })
      response.should eq("en"=>nil)
      stub.should have_been_requested
      Alert.count.should == 1
      alert = Alert.first
      alert.class_name.should eq("Net::HTTPBadRequest")
      alert.status.should == 400
      alert.source_id.should == subject.id
    end

    it "should catch timeout errors with the Wikipedia API" do
      article = FactoryGirl.build(:article, :doi => "10.1371/journal.pone.0000001")
      stub = stub_request(:get, /en.wikipedia.org/).to_return(:status => [408])
      response = subject.get_data(article, options = { :source_id => subject.id })
      response.should eq("en"=>nil)
      stub.should have_been_requested
      Alert.count.should == 1
      alert = Alert.first
      alert.class_name.should eq("Net::HTTPRequestTimeOut")
      alert.status.should == 408
      alert.source_id.should == subject.id
    end
  end

  context "get_data from Wikimedia Commons" do
    subject { FactoryGirl.create(:wikipedia, languages: "en commons") }

    it "should report if there are events and event_count returned by the Wikimedia Commons API" do
      article = FactoryGirl.build(:article, :doi => "10.1371/journal.pone.0044271")
      body = File.read(fixture_path + 'wikipedia_commons.json')
      stub = stub_request(:get, /en.wikipedia.org/).to_return(:headers => { "Content-Type" => "application/json" }, :body => File.read(fixture_path + 'wikipedia.json'), :status => 200)
      stub_commons = stub_request(:get, /commons.wikimedia.org/).to_return(:headers => { "Content-Type" => "application/json" }, :body => body, :status => 200)
      response = subject.get_data(article)
      response.should eq("en"=>12, "commons"=>8)
      stub.should have_been_requested
    end

  end

  context "parse_data" do
    it "should report if the doi is missing" do
      article = FactoryGirl.build(:article, :doi => nil)
      result = {}
      subject.parse_data(result, article).should eq(events: {}, :events_by_day=>[], :events_by_month=>[], events_url: nil, event_count: 0, event_metrics: { pdf: nil, html: nil, shares: nil, groups: nil, comments: nil, likes: nil, citations: 0, total: 0 })
    end

    it "should report if there are no events and event_count returned by the Wikipedia API" do
      result = { "en"=>0 }
      subject.parse_data(result, article).should eq(events: {"en"=>0, "total"=>0}, :events_by_day=>[], :events_by_month=>[], events_url: "http://en.wikipedia.org/w/index.php?search=\"#{article.doi_escaped}\"", event_count: 0, event_metrics: { pdf: nil, html: nil, shares: nil, groups: nil, comments: nil, likes: nil, citations: 0, total: 0 })
    end

    it "should report if there are events and event_count returned by the Wikipedia API" do
      article = FactoryGirl.build(:article, :doi => "10.1371/journal.pcbi.1002445")
      result = { "en"=>12 }
      response = subject.parse_data(result, article)
      response[:events].length.should == 1 + 1
      response[:event_count].should == 12
    end

    it "should report if there are events and event_count returned by the Wikimedia Commons API" do
      article = FactoryGirl.build(:article, :doi => "10.1371/journal.pone.0044271")
      result = { "en"=>12, "commons"=>8 }
      response = subject.parse_data(result, article)
      response[:events].length.should == 1 + 1 + 1
      response[:event_count].should == 12 + 8
    end

    it "should catch errors with the Wikipedia API" do
      article = FactoryGirl.create(:article, :doi => "10.2307/683422")
      result = { "en"=>nil }
      response = subject.parse_data(result, article)
      response.should eq(:events=>{"en"=>nil, "total"=>0}, :events_by_day=>[], :events_by_month=>[], :events_url=>"http://en.wikipedia.org/w/index.php?search=\"#{article.doi_escaped}\"", :event_count=>0, :event_metrics=>{:pdf=>nil, :html=>nil, :shares=>nil, :groups=>nil, :comments=>nil, :likes=>nil, :citations=>0, :total=>0})
    end
  end
end
