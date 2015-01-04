require 'rails_helper'

describe ScienceSeeker, type: :model, vcr: true do
  subject { FactoryGirl.create(:science_seeker) }

  context "get_data" do
    it "should report that there are no events if the doi is missing" do
      work_without_doi = FactoryGirl.build(:work, :doi => "")
      expect(subject.get_data(work_without_doi)).to eq({})
    end

    it "should report if there are no events and event_count returned by the ScienceSeeker API" do
      work = FactoryGirl.build(:work, :doi => "10.1371/journal.pmed.0020124")
      body = File.read(fixture_path + 'science_seeker_nil.xml')
      stub = stub_request(:get, subject.get_query_url(work)).to_return(:body => body)
      response = subject.get_data(work)
      expect(response).to eq(Hash.from_xml(body))
      expect(stub).to have_been_requested
    end

    it "should report if there is an incomplete response returned by the ScienceSeeker API" do
      work = FactoryGirl.build(:work, :doi => "10.1371/journal.pmed.0020124")
      body = File.read(fixture_path + 'science_seeker_incomplete.xml')
      stub = stub_request(:get, subject.get_query_url(work)).to_return(:body => body)
      response = subject.get_data(work)
      expect(response).to eq(Hash.from_xml(body))
      expect(stub).to have_been_requested
    end

    it "should report if there are events and event_count returned by the ScienceSeeker API" do
      work = FactoryGirl.build(:work, :doi => "10.1371/journal.pone.0035869")
      body = File.read(fixture_path + 'science_seeker.xml')
      stub = stub_request(:get, subject.get_query_url(work)).to_return(:body => body)
      response = subject.get_data(work)
      expect(response).to eq(Hash.from_xml(body))
      expect(stub).to have_been_requested
    end

    it "should catch errors with the ScienceSeeker API" do
      work = FactoryGirl.build(:work, :doi => "10.1371/journal.pone.0000001")
      stub = stub_request(:get, subject.get_query_url(work)).to_return(:status => [408])
      response = subject.get_data(work, options = { :source_id => subject.id })
      expect(response).to eq(error: "the server responded with status 408 for http://scienceseeker.org/search/default/?type=post&filter0=citation&modifier0=doi&value0=#{work.doi_escaped}", :status=>408)
      expect(stub).to have_been_requested
      expect(Alert.count).to eq(1)
      alert = Alert.first
      expect(alert.class_name).to eq("Net::HTTPRequestTimeOut")
      expect(alert.status).to eq(408)
      expect(alert.source_id).to eq(subject.id)
    end
  end

  context "parse_data" do
    let(:work) { FactoryGirl.build(:work, :doi => "10.1371/journal.pmed.0020124") }

    it "should report if the doi is missing" do
      work = FactoryGirl.build(:work, :doi => "")
      result = {}
      result.extend Hashie::Extensions::DeepFetch
      expect(subject.parse_data(result, work)).to eq(events: [], :events_by_day=>[], :events_by_month=>[], events_url: nil, event_count: 0, event_metrics: { pdf: nil, html: nil, shares: nil, groups: nil, comments: nil, likes: nil, citations: 0, total: 0 })
    end

    it "should report if there are no events and event_count returned by the ScienceSeeker API" do
      body = File.read(fixture_path + 'science_seeker_nil.xml')
      result = Hash.from_xml(body)
      result.extend Hashie::Extensions::DeepFetch
      response = subject.parse_data(result, work)
      expect(response).to eq(events: [], :events_by_day=>[], :events_by_month=>[], event_count: 0, event_metrics: { pdf: nil, html: nil, shares: nil, groups: nil, comments: nil, likes: nil, citations: 0, total: 0 }, events_url: nil)
    end

    it "should report if there is an incomplete response returned by the ScienceSeeker API" do
      body = File.read(fixture_path + 'science_seeker_incomplete.xml')
      result = Hash.from_xml(body)
      result.extend Hashie::Extensions::DeepFetch
      response = subject.parse_data(result, work)
      expect(response).to eq(events: [], :events_by_day=>[], :events_by_month=>[], event_count: 0, event_metrics: { pdf: nil, html: nil, shares: nil, groups: nil, comments: nil, likes: nil, citations: 0, total: 0 }, events_url: nil)
    end

    it "should report if there are events and event_count returned by the ScienceSeeker API" do
      work = FactoryGirl.build(:work, doi: "10.1371/journal.pone.0035869", published_on: "2012-05-03")
      body = File.read(fixture_path + 'science_seeker.xml')
      result = Hash.from_xml(body)
      result.extend Hashie::Extensions::DeepFetch
      response = subject.parse_data(result, work)
      expect(response[:event_count]).to eq(3)
      expect(response[:events_url]).to eq("http://scienceseeker.org/posts/?filter0=citation&modifier0=doi&value0=#{work.doi_escaped}")

      expect(response[:events_by_day].length).to eq(3)
      expect(response[:events_by_day].first).to eq(year: 2012, month: 5, day: 11, total: 1)
      expect(response[:events_by_month].length).to eq(1)
      expect(response[:events_by_month].first).to eq(year: 2012, month: 5, total: 3)

      event = response[:events].first

      expect(event[:event_csl]['author']).to eq([{"family"=>"Duncan", "given"=>""}])
      expect(event[:event_csl]['title']).to eq("Web analytics: Numbers speak louder than words")
      expect(event[:event_csl]['container-title']).to eq("O'Really?")
      expect(event[:event_csl]['issued']).to eq("date-parts"=>[[2012, 5, 18]])
      expect(event[:event_csl]['type']).to eq("post")

      expect(event[:event_time]).to eq("2012-05-18T07:58:34Z")
      expect(event[:event_url]).to eq(event[:event]['link']['href'])
    end

    it "should report if there is one event returned by the ScienceSeeker API" do
      work = FactoryGirl.build(:work, doi: "10.1371/journal.pone.0035869", published_on: "2012-05-03")
      body = File.read(fixture_path + 'science_seeker_one.xml')
      result = Hash.from_xml(body)
      result.extend Hashie::Extensions::DeepFetch
      response = subject.parse_data(result, work)
      expect(response[:event_count]).to eq(1)
      expect(response[:events_url]).to eq("http://scienceseeker.org/posts/?filter0=citation&modifier0=doi&value0=#{work.doi_escaped}")

      expect(response[:events_by_day].length).to eq(1)
      expect(response[:events_by_day].first).to eq(year: 2012, month: 5, day: 18, total: 1)
      expect(response[:events_by_month].length).to eq(1)
      expect(response[:events_by_month].first).to eq(year: 2012, month: 5, total: 1)

      event = response[:events].first

      expect(event[:event_csl]['author']).to eq([{"family"=>"Duncan", "given"=>""}])
      expect(event[:event_csl]['title']).to eq("Web analytics: Numbers speak louder than words")
      expect(event[:event_csl]['container-title']).to eq("O'Really?")
      expect(event[:event_csl]['issued']).to eq("date-parts"=>[[2012, 5, 18]])
      expect(event[:event_csl]['type']).to eq("post")

      expect(event[:event_time]).to eq("2012-05-18T07:58:34Z")
      expect(event[:event_url]).to eq(event[:event]['link']['href'])
    end

    it "should catch timeout errors with the ScienceSeeker API" do
      work = FactoryGirl.create(:work, :doi => "10.2307/683422")
      result = { error: "the server responded with status 408 for http://scienceseeker.org/search/default/?type=post&filter0=citation&modifier0=doi&value0=#{work.doi_escaped}", status: 408 }
      response = subject.parse_data(result, work)
      expect(response).to eq(result)
    end
  end
end
