require 'spec_helper'

describe ScienceSeeker do
  let(:science_seeker) { FactoryGirl.create(:science_seeker) }

  it "should report that there are no events if the doi is missing" do
    article_without_doi = FactoryGirl.build(:article, :doi => "")
    science_seeker.parse_data(article_without_doi).should eq(events: [], event_count: nil)
  end

  context "use the ScienceSeeker API" do
    it "should report if there are no events and event_count returned by the ScienceSeeker API" do
      article = FactoryGirl.build(:article, :doi => "10.1371/journal.pmed.0020124")
      stub = stub_request(:get, science_seeker.get_query_url(article)).to_return(:body => File.read(fixture_path + 'science_seeker_nil.xml'), :status => 200)
      science_seeker.parse_data(article).should eq(events: [], event_count: 0, event_metrics: { pdf: nil, html: nil, shares: nil, groups: nil, comments: nil, likes: nil, citations: 0, total: 0 }, events_url: "http://scienceseeker.org/posts/?filter0=citation&modifier0=doi&value0=#{article.doi}")
      stub.should have_been_requested
    end

    it "should report if there is an incomplete response returned by the ScienceSeeker API" do
      article = FactoryGirl.build(:article, :doi => "10.1371/journal.pmed.0020124")
      stub = stub_request(:get, science_seeker.get_query_url(article)).to_return(:body => File.read(fixture_path + 'science_seeker_incomplete.xml'), :status => 200)
      science_seeker.parse_data(article).should eq(events: [], event_count: 0, event_metrics: { pdf: nil, html: nil, shares: nil, groups: nil, comments: nil, likes: nil, citations: 0, total: 0 }, events_url: "http://scienceseeker.org/posts/?filter0=citation&modifier0=doi&value0=#{article.doi}")
      stub.should have_been_requested
    end

    it "should report if there are events and event_count returned by the ScienceSeeker API" do
      article = FactoryGirl.build(:article, :doi => "10.1371/journal.pone.0035869")
      stub = stub_request(:get, science_seeker.get_query_url(article)).to_return(:body => File.read(fixture_path + 'science_seeker.xml'), :status => 200)
      response = science_seeker.parse_data(article)
      response[:event_count].should eq(3)
      response[:events_url].should eq("http://scienceseeker.org/posts/?filter0=citation&modifier0=doi&value0=#{article.doi}")
      event = response[:events].first
      event[:event_url].should_not be_nil
      event[:event_url].should eq(event[:event]['link']['href'])
      stub.should have_been_requested
    end

    it "should catch errors with the ScienceSeeker API" do
      article = FactoryGirl.build(:article, :doi => "10.1371/journal.pone.0000001")
      stub = stub_request(:get, science_seeker.get_query_url(article)).to_return(:status => [408])
      science_seeker.parse_data(article, options = { :source_id => science_seeker.id }).should be_nil
      stub.should have_been_requested
      Alert.count.should == 1
      alert = Alert.first
      alert.class_name.should eq("Net::HTTPRequestTimeOut")
      alert.status.should == 408
      alert.source_id.should == science_seeker.id
    end
  end
end
