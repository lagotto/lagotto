require 'rails_helper'

describe Researchblogging do
  subject { FactoryGirl.create(:researchblogging) }

  context "get_data" do
    let(:auth) { ActionController::HttpAuthentication::Basic.encode_credentials(subject.username, subject.password) }

    it "should report that there are no events if the doi is missing" do
      article = FactoryGirl.build(:article, :doi => "")
      subject.get_data(article).should eq({})
    end

    it "should report if there are no events and event_count returned by the ResearchBlogging API" do
      article = FactoryGirl.build(:article, :doi => "10.1371/journal.pmed.0020124")
      body = File.read(fixture_path + 'researchblogging_nil.xml')
      stub = stub_request(:get, "http://researchbloggingconnect.com/blogposts?article=doi:#{article.doi_escaped}&count=100").with(:headers => { :authorization => auth }).to_return(:body => body)
      response = subject.get_data(article)
      response.should eq(Hash.from_xml(body))
      stub.should have_been_requested
    end

    it "should report if there are events and event_count returned by the ResearchBlogging API" do
      article = FactoryGirl.build(:article, :doi => "10.1371/journal.pone.0035869")
      body = File.read(fixture_path + 'researchblogging.xml')
      stub = stub_request(:get, "http://researchbloggingconnect.com/blogposts?article=doi:#{article.doi_escaped}&count=100").with(:headers => { :authorization => auth }).to_return(:body => body)
      response = subject.get_data(article)
      response.should eq(Hash.from_xml(body))
      stub.should have_been_requested
    end

    it "should catch errors with the ResearchBlogging API" do
      article = FactoryGirl.build(:article, :doi => "10.1371/journal.pone.0000001")
      stub = stub_request(:get, "http://researchbloggingconnect.com/blogposts?article=doi:#{article.doi_escaped}&count=100").with(:headers => { :authorization => auth }).to_return(:status => [408])
      response = subject.get_data(article, options = { :source_id => subject.id })
      response.should eq(error: "the server responded with status 408 for http://researchbloggingconnect.com/blogposts?count=100&article=doi:#{article.doi_escaped}", :status=>408)
      stub.should have_been_requested
      Alert.count.should == 1
      alert = Alert.first
      alert.class_name.should eq("Net::HTTPRequestTimeOut")
      alert.status.should == 408
      alert.source_id.should == subject.id
    end
  end

  context "parse_data" do
    let(:article) { FactoryGirl.build(:article, :doi => "10.1371/journal.pmed.0020124") }

    it "should report if the doi is missing" do
      article = FactoryGirl.build(:article, :doi => "")
      result = {}
      result.extend Hashie::Extensions::DeepFetch
      subject.parse_data(result, article).should eq(events: [], :events_by_day=>[], :events_by_month=>[], events_url: nil, event_count: 0, event_metrics: { pdf: nil, html: nil, shares: nil, groups: nil, comments: nil, likes: nil, citations: 0, total: 0 })
    end

    it "should report if there are no events and event_count returned by the ResearchBlogging API" do
      body = File.read(fixture_path + 'researchblogging_nil.xml')
      result = Hash.from_xml(body)
      result.extend Hashie::Extensions::DeepFetch
      response = subject.parse_data(result, article)
      response.should eq(events: [], :events_by_day=>[], :events_by_month=>[], event_count: 0, event_metrics: { pdf: nil, html: nil, shares: nil, groups: nil, comments: nil, likes: nil, citations: 0, total: 0 }, events_url: subject.get_events_url(article))
    end

    it "should report if there are events and event_count returned by the ResearchBlogging API" do
      article = FactoryGirl.build(:article, :doi => "10.1371/journal.pone.0035869", published_on: "2009-07-01")
      body = File.read(fixture_path + 'researchblogging.xml')
      result = Hash.from_xml(body)
      result.extend Hashie::Extensions::DeepFetch
      response = subject.parse_data(result, article)
      response[:event_count].should eq(8)
      response[:events].length.should eq(8)
      response[:events_url].should eq(subject.get_events_url(article))

      response[:events_by_day].length.should eq(1)
      response[:events_by_day].first.should eq(year: 2009, month: 7, day: 6, total: 1)
      response[:events_by_month].length.should eq(7)
      response[:events_by_month].first.should eq(year: 2009, month: 7, total: 1)

      event = response[:events].first

      event[:event_csl]['author'].should eq([{"family"=>"Spoetnik", "given"=>"Laika"}])
      event[:event_csl]['title'].should eq("Why Publishing in the NEJM is not the Best Guarantee that Something is True: a Response to Katan")
      event[:event_csl]['container-title'].should eq("Laika's Medliblog")
      event[:event_csl]['issued'].should eq("date-parts"=>[[2012, 10, 27]])
      event[:event_csl]['type'].should eq("post")

      event[:event_time].should eq("2012-10-27T11:32:09Z")
      event[:event_url].should eq(event[:event]["post_URL"])
    end

    it "should report if there is one event returned by the ResearchBlogging API" do
      article = FactoryGirl.build(:article, :doi => "10.1371/journal.pone.0035869", published_on: "2012-10-01")
      body = File.read(fixture_path + 'researchblogging_one.xml')
      result = Hash.from_xml(body)
      result.extend Hashie::Extensions::DeepFetch
      response = subject.parse_data(result, article)
      response[:event_count].should eq(1)
      response[:events].length.should eq(1)
      response[:events_url].should eq(subject.get_events_url(article))

      response[:events_by_day].length.should eq(1)
      response[:events_by_day].first.should eq(year: 2012, month: 10, day: 27, total: 1)
      response[:events_by_month].length.should eq(1)
      response[:events_by_month].first.should eq(year: 2012, month: 10, total: 1)

      event = response[:events].first

      event[:event_csl]['author'].should eq([{"family"=>"Spoetnik", "given"=>"Laika"}])
      event[:event_csl]['title'].should eq("Why Publishing in the NEJM is not the Best Guarantee that Something is True: a Response to Katan")
      event[:event_csl]['container-title'].should eq("Laika's Medliblog")
      event[:event_csl]['issued'].should eq("date-parts"=>[[2012, 10, 27]])
      event[:event_csl]['type'].should eq("post")

      event[:event_time].should eq("2012-10-27T11:32:09Z")
      event[:event_url].should eq(event[:event]["post_URL"])
    end

    it "should catch timeout errors with the ResearchBlogging API" do
      result = { error: "the server responded with status 408 for http://researchbloggingconnect.com/blogposts?count=100&article=doi:#{article.doi_escaped}", status: 408 }
      response = subject.parse_data(result, article)
      response.should eq(result)
    end
  end
end
