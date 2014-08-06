require 'spec_helper'

describe ScienceSeeker do
  subject { FactoryGirl.create(:science_seeker) }

  context "get_data" do
    it "should report that there are no events if the doi is missing" do
      article_without_doi = FactoryGirl.build(:article, :doi => "")
      subject.get_data(article_without_doi).should eq({})
    end

    it "should report if there are no events and event_count returned by the ScienceSeeker API" do
      article = FactoryGirl.build(:article, :doi => "10.1371/journal.pmed.0020124")
      body = File.read(fixture_path + 'science_seeker_nil.xml')
      stub = stub_request(:get, subject.get_query_url(article)).to_return(:body => body)
      response = subject.get_data(article)
      response.should eq(Hash.from_xml(body))
      stub.should have_been_requested
    end

    it "should report if there is an incomplete response returned by the ScienceSeeker API" do
      article = FactoryGirl.build(:article, :doi => "10.1371/journal.pmed.0020124")
      body = File.read(fixture_path + 'science_seeker_incomplete.xml')
      stub = stub_request(:get, subject.get_query_url(article)).to_return(:body => body)
      response = subject.get_data(article)
      response.should eq(Hash.from_xml(body))
      stub.should have_been_requested
    end

    it "should report if there are events and event_count returned by the ScienceSeeker API" do
      article = FactoryGirl.build(:article, :doi => "10.1371/journal.pone.0035869")
      body = File.read(fixture_path + 'science_seeker.xml')
      stub = stub_request(:get, subject.get_query_url(article)).to_return(:body => body)
      response = subject.get_data(article)
      response.should eq(Hash.from_xml(body))
      stub.should have_been_requested
    end

    it "should catch errors with the ScienceSeeker API" do
      article = FactoryGirl.build(:article, :doi => "10.1371/journal.pone.0000001")
      stub = stub_request(:get, subject.get_query_url(article)).to_return(:status => [408])
      response = subject.get_data(article, options = { :source_id => subject.id })
      response.should eq(error: "the server responded with status 408 for http://scienceseeker.org/search/default/?type=post&filter0=citation&modifier0=doi&value0=#{article.doi_escaped}", :status=>408)
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

    it "should report if there are no events and event_count returned by the ScienceSeeker API" do
      body = File.read(fixture_path + 'science_seeker_nil.xml')
      result = Hash.from_xml(body)
      result.extend Hashie::Extensions::DeepFetch
      response = subject.parse_data(result, article)
      response.should eq(events: [], :events_by_day=>[], :events_by_month=>[], event_count: 0, event_metrics: { pdf: nil, html: nil, shares: nil, groups: nil, comments: nil, likes: nil, citations: 0, total: 0 }, events_url: "http://scienceseeker.org/posts/?filter0=citation&modifier0=doi&value0=#{article.doi_escaped}")
    end

    it "should report if there is an incomplete response returned by the ScienceSeeker API" do
      body = File.read(fixture_path + 'science_seeker_incomplete.xml')
      result = Hash.from_xml(body)
      result.extend Hashie::Extensions::DeepFetch
      response = subject.parse_data(result, article)
      response.should eq(events: [], :events_by_day=>[], :events_by_month=>[], event_count: 0, event_metrics: { pdf: nil, html: nil, shares: nil, groups: nil, comments: nil, likes: nil, citations: 0, total: 0 }, events_url: "http://scienceseeker.org/posts/?filter0=citation&modifier0=doi&value0=#{article.doi_escaped}")
    end

    it "should report if there are events and event_count returned by the ScienceSeeker API" do
      article = FactoryGirl.build(:article, doi: "10.1371/journal.pone.0035869", published_on: "2012-05-03")
      body = File.read(fixture_path + 'science_seeker.xml')
      result = Hash.from_xml(body)
      result.extend Hashie::Extensions::DeepFetch
      response = subject.parse_data(result, article)
      response[:event_count].should eq(3)
      response[:events_url].should eq("http://scienceseeker.org/posts/?filter0=citation&modifier0=doi&value0=#{article.doi_escaped}")

      response[:events_by_day].length.should eq(3)
      response[:events_by_day].first.should eq(year: 2012, month: 5, day: 11, total: 1)
      response[:events_by_month].length.should eq(1)
      response[:events_by_month].first.should eq(year: 2012, month: 5, total: 3)

      event = response[:events].first

      event[:event_csl]['author'].should eq([{"family"=>"Duncan", "given"=>""}])
      event[:event_csl]['title'].should eq("Web analytics: Numbers speak louder than words")
      event[:event_csl]['container-title'].should eq("O'Really?")
      event[:event_csl]['issued'].should eq("date-parts"=>[[2012, 5, 18]])
      event[:event_csl]['type'].should eq("post")

      event[:event_time].should eq("2012-05-18T07:58:34Z")
      event[:event_url].should eq(event[:event]['link']['href'])
    end

    it "should report if there is one event returned by the ScienceSeeker API" do
      article = FactoryGirl.build(:article, doi: "10.1371/journal.pone.0035869", published_on: "2012-05-03")
      body = File.read(fixture_path + 'science_seeker_one.xml')
      result = Hash.from_xml(body)
      result.extend Hashie::Extensions::DeepFetch
      response = subject.parse_data(result, article)
      response[:event_count].should eq(1)
      response[:events_url].should eq("http://scienceseeker.org/posts/?filter0=citation&modifier0=doi&value0=#{article.doi_escaped}")

      response[:events_by_day].length.should eq(1)
      response[:events_by_day].first.should eq(year: 2012, month: 5, day: 18, total: 1)
      response[:events_by_month].length.should eq(1)
      response[:events_by_month].first.should eq(year: 2012, month: 5, total: 1)

      event = response[:events].first

      event[:event_csl]['author'].should eq([{"family"=>"Duncan", "given"=>""}])
      event[:event_csl]['title'].should eq("Web analytics: Numbers speak louder than words")
      event[:event_csl]['container-title'].should eq("O'Really?")
      event[:event_csl]['issued'].should eq("date-parts"=>[[2012, 5, 18]])
      event[:event_csl]['type'].should eq("post")

      event[:event_time].should eq("2012-05-18T07:58:34Z")
      event[:event_url].should eq(event[:event]['link']['href'])
    end

    it "should catch timeout errors with the ScienceSeeker API" do
      article = FactoryGirl.create(:article, :doi => "10.2307/683422")
      result = { error: "the server responded with status 408 for http://scienceseeker.org/search/default/?type=post&filter0=citation&modifier0=doi&value0=#{article.doi_escaped}", status: 408 }
      response = subject.parse_data(result, article)
      response.should eq(result)
    end
  end
end
