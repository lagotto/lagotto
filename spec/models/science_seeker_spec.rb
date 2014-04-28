require 'spec_helper'

describe ScienceSeeker do
  subject { FactoryGirl.create(:science_seeker) }

  context "get_data" do
    it "should report that there are no events if the doi is missing" do
      article_without_doi = FactoryGirl.build(:article, :doi => "")
      subject.get_data(article_without_doi).should eq(events: [], event_count: nil)
    end

    it "should report if there are no events and event_count returned by the ScienceSeeker API" do
      article = FactoryGirl.build(:article, :doi => "10.1371/journal.pmed.0020124")
      body = File.read(fixture_path + 'science_seeker_nil.xml')
      stub = stub_request(:get, subject.get_query_url(article)).to_return(:body => body, :status => 200)
      response = subject.get_data(article)
      response.should eq(Hash.from_xml(body))
      stub.should have_been_requested
    end

    it "should report if there is an incomplete response returned by the ScienceSeeker API" do
      article = FactoryGirl.build(:article, :doi => "10.1371/journal.pmed.0020124")
      body = File.read(fixture_path + 'science_seeker_incomplete.xml')
      stub = stub_request(:get, subject.get_query_url(article)).to_return(:body => body, :status => 200)
      response = subject.get_data(article)
      response.should eq(Hash.from_xml(body))
      stub.should have_been_requested
    end

    it "should report if there are events and event_count returned by the ScienceSeeker API" do
      article = FactoryGirl.build(:article, :doi => "10.1371/journal.pone.0035869")
      body = File.read(fixture_path + 'science_seeker.xml')
      stub = stub_request(:get, subject.get_query_url(article)).to_return(:body => body, :status => 200)
      response = subject.get_data(article)
      response.should eq(Hash.from_xml(body))
      stub.should have_been_requested
    end

    it "should catch errors with the ScienceSeeker API" do
      article = FactoryGirl.build(:article, :doi => "10.1371/journal.pone.0000001")
      stub = stub_request(:get, subject.get_query_url(article)).to_return(:status => [408])
      subject.get_data(article, options = { :source_id => subject.id }).should be_nil
      stub.should have_been_requested
      Alert.count.should == 1
      alert = Alert.first
      alert.class_name.should eq("Net::HTTPRequestTimeOut")
      alert.status.should == 408
      alert.source_id.should == subject.id
    end
  end

  context "parse_data" do
    it "should report if there are no events and event_count returned by the ScienceSeeker API" do
      article = FactoryGirl.build(:article, :doi => "10.1371/journal.pmed.0020124")
      body = File.read(fixture_path + 'science_seeker_nil.xml')
      result = Hash.from_xml(body)
      response = subject.parse_data(result, article: article)
      response.should eq(events: [], event_count: 0, event_metrics: { pdf: nil, html: nil, shares: nil, groups: nil, comments: nil, likes: nil, citations: 0, total: 0 }, events_url: "http://scienceseeker.org/posts/?filter0=citation&modifier0=doi&value0=#{article.doi}")
    end

    it "should report if there is an incomplete response returned by the ScienceSeeker API" do
      article = FactoryGirl.build(:article, :doi => "10.1371/journal.pmed.0020124")
      body = File.read(fixture_path + 'science_seeker_incomplete.xml')
      result = Hash.from_xml(body)
      response = subject.parse_data(result, article: article)
      response.should eq(events: [], event_count: 0, event_metrics: { pdf: nil, html: nil, shares: nil, groups: nil, comments: nil, likes: nil, citations: 0, total: 0 }, events_url: "http://scienceseeker.org/posts/?filter0=citation&modifier0=doi&value0=#{article.doi}")
    end

    it "should report if there are events and event_count returned by the ScienceSeeker API" do
      article = FactoryGirl.build(:article, :doi => "10.1371/journal.pone.0035869")
      body = File.read(fixture_path + 'science_seeker.xml')
      result = Hash.from_xml(body)
      response = subject.parse_data(result, article: article)
      response[:event_count].should eq(3)
      response[:events_url].should eq("http://scienceseeker.org/posts/?filter0=citation&modifier0=doi&value0=#{article.doi}")
      event = response[:events].first
      event[:event_url].should_not be_nil
      event[:event_url].should eq(event[:event]['link']['href'])
    end
  end
end
