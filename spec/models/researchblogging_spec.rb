require 'spec_helper'

describe Researchblogging do
  subject { FactoryGirl.create(:researchblogging) }

  context "get_data" do
    let(:auth) { ActionController::HttpAuthentication::Basic.encode_credentials(subject.username, subject.password) }

    it "should report that there are no events if the doi is missing" do
      article = FactoryGirl.build(:article, :doi => "")
      subject.get_data(article).should eq(events: [], event_count: nil)
    end

    it "should report if there are no events and event_count returned by the ResearchBlogging API" do
      article = FactoryGirl.build(:article, :doi => "10.1371/journal.pmed.0020124")
      body = File.read(fixture_path + 'researchblogging_nil.xml')
      stub = stub_request(:get, "http://researchbloggingconnect.com/blogposts?article=doi:#{article.doi_escaped}&count=100").with(:headers => { :authorization => auth }).to_return(:body => body, :status => 200)
      response = subject.get_data(article)
      response.should eq(Hash.from_xml(body))
      stub.should have_been_requested
    end

    it "should report if there are events and event_count returned by the ResearchBlogging API" do
      article = FactoryGirl.build(:article, :doi => "10.1371/journal.pone.0035869")
      body = File.read(fixture_path + 'researchblogging.xml')
      stub = stub_request(:get, "http://researchbloggingconnect.com/blogposts?article=doi:#{article.doi_escaped}&count=100").with(:headers => { :authorization => auth }).to_return(:body => body, :status => 200)
      response = subject.get_data(article)
      response.should eq(Hash.from_xml(body))
      stub.should have_been_requested
    end

    it "should catch errors with the ResearchBlogging API" do
      article = FactoryGirl.build(:article, :doi => "10.1371/journal.pone.0000001")
      stub = stub_request(:get, "http://researchbloggingconnect.com/blogposts?article=doi:#{article.doi_escaped}&count=100").with(:headers => { :authorization => auth }).to_return(:status => [408])
      response = subject.get_data(article, options = { :source_id => subject.id })
      response.should eq(error: "the server responded with status 408 for http://researchbloggingconnect.com/blogposts?count=100&article=doi:#{article.doi_escaped}")
      stub.should have_been_requested
      Alert.count.should == 1
      alert = Alert.first
      alert.class_name.should eq("Net::HTTPRequestTimeOut")
      alert.status.should == 408
      alert.source_id.should == subject.id
    end
  end

  context "parse_data" do
    it "should report if there are no events and event_count returned by the ResearchBlogging API" do
      article = FactoryGirl.build(:article, :doi => "10.1371/journal.pmed.0020124")
      body = File.read(fixture_path + 'researchblogging_nil.xml')
      result = Hash.from_xml(body)
      response = subject.parse_data(result, article)
      response.should eq(events: [], event_count: 0, event_metrics: { pdf: nil, html: nil, shares: nil, groups: nil, comments: nil, likes: nil, citations: 0, total: 0 }, events_url: subject.get_events_url(article))
    end

    it "should report if there are events and event_count returned by the ResearchBlogging API" do
      article = FactoryGirl.build(:article, :doi => "10.1371/journal.pone.0035869")
      body = File.read(fixture_path + 'researchblogging.xml')
      result = Hash.from_xml(body)
      response = subject.parse_data(result, article)
      response[:event_count].should eq(8)
      response[:events].length.should eq(8)
      response[:events_url].should eq(subject.get_events_url(article))
      event = response[:events].first
      event[:event_url].should eq(event[:event]["post_URL"])
    end

    it "should catch timeout errors with the ResearchBlogging API" do
      article = FactoryGirl.create(:article, :doi => "10.2307/683422")
      result = { error: "the server responded with status 408 for http://researchbloggingconnect.com/blogposts?count=100&article=doi:#{article.doi_escaped}" }
      response = subject.parse_data(result, article)
      response.should eq(result)
    end
  end
end
