require 'rails_helper'

describe ScienceSeeker, type: :model, vcr: true do
  subject { FactoryGirl.create(:science_seeker) }

  context "get_data" do
    it "should report that there are no events if the doi is missing" do
      work = FactoryGirl.create(:work, :doi => "")
      expect(subject.get_data(work)).to eq({})
    end

    it "should report if there are no events and event_count returned by the ScienceSeeker API" do
      work = FactoryGirl.create(:work, :doi => "10.1371/journal.pmed.0020124")
      body = File.read(fixture_path + 'science_seeker_nil.xml')
      stub = stub_request(:get, subject.get_query_url(work)).to_return(:body => body)
      response = subject.get_data(work)
      expect(response).to eq(Hash.from_xml(body))
      expect(stub).to have_been_requested
    end

    it "should report if there is an incomplete response returned by the ScienceSeeker API" do
      work = FactoryGirl.create(:work, :doi => "10.1371/journal.pmed.0020124")
      body = File.read(fixture_path + 'science_seeker_incomplete.xml')
      stub = stub_request(:get, subject.get_query_url(work)).to_return(:body => body)
      response = subject.get_data(work)
      expect(response).to eq(Hash.from_xml(body))
      expect(stub).to have_been_requested
    end

    it "should report if there are events and event_count returned by the ScienceSeeker API" do
      work = FactoryGirl.create(:work, :doi => "10.1371/journal.pone.0035869")
      body = File.read(fixture_path + 'science_seeker.xml')
      stub = stub_request(:get, subject.get_query_url(work)).to_return(:body => body)
      response = subject.get_data(work)
      expect(response).to eq(Hash.from_xml(body))
      expect(stub).to have_been_requested
    end

    it "should catch errors with the ScienceSeeker API" do
      work = FactoryGirl.create(:work, :doi => "10.1371/journal.pone.0000001")
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
    let(:work) { FactoryGirl.create(:work, :doi => "10.1371/journal.pmed.0020124") }

    it "should report if the doi is missing" do
      work = FactoryGirl.create(:work, :doi => "")
      result = {}
      result.extend Hashie::Extensions::DeepFetch
      expect(subject.parse_data(result, work)).to eq(works: [], events: { source: "scienceseeker", work: work.pid, total: 0, extra: [], days: [], months: [] })
    end

    it "should report if there are no events and event_count returned by the ScienceSeeker API" do
      body = File.read(fixture_path + 'science_seeker_nil.xml')
      result = Hash.from_xml(body)
      result.extend Hashie::Extensions::DeepFetch
      response = subject.parse_data(result, work)
      expect(response).to eq(works: [], events: { source: "scienceseeker", work: work.pid, total: 0, extra: [], days: [], months: [] })
    end

    it "should report if there is an incomplete response returned by the ScienceSeeker API" do
      body = File.read(fixture_path + 'science_seeker_incomplete.xml')
      result = Hash.from_xml(body)
      response = subject.parse_data(result, work)
      expect(response).to eq(works: [], events: { source: "scienceseeker", work: work.pid, total: 0, extra: [], days: [], months: [] })
    end

    it "should report if there are events and event_count returned by the ScienceSeeker API" do
      work = FactoryGirl.create(:work, doi: "10.1371/journal.pone.0035869", published_on: "2012-05-03")
      body = File.read(fixture_path + 'science_seeker.xml')
      result = Hash.from_xml(body)
      result.extend Hashie::Extensions::DeepFetch
      response = subject.parse_data(result, work)
      expect(response[:works].length).to eq(3)
      expect(response[:events][:total]).to eq(3)
      expect(response[:events][:events_url]).to eq("http://scienceseeker.org/posts/?filter0=citation&modifier0=doi&value0=#{work.doi_escaped}")
      expect(response[:events][:days].length).to eq(3)
      expect(response[:events][:days].first).to eq(year: 2012, month: 5, day: 11, total: 1)
      expect(response[:events][:months].length).to eq(1)
      expect(response[:events][:months].first).to eq(year: 2012, month: 5, total: 3)

      event = response[:works].first
      expect(event['URL']).to eq("http://duncan.hull.name/2012/05/18/two-ton/")
      expect(event['author']).to eq([{"family"=>"Duncan", "given"=>""}])
      expect(event['title']).to eq("Web analytics: Numbers speak louder than words")
      expect(event['container-title']).to eq("O'Really?")
      expect(event['issued']).to eq("date-parts"=>[[2012, 5, 18]])
      expect(event['type']).to eq("post")
      expect(event['related_works']).to eq([{"related_work"=>"doi:10.1371/journal.pone.0035869", "source"=>"scienceseeker", "relation_type"=>"discusses"}])

      extra = response[:events][:extra].first
      expect(extra[:event_time]).to eq("2012-05-18T07:58:34Z")
      expect(extra[:event_url]).to eq(extra[:event]['link']['href'])
      expect(extra[:event_csl]['author']).to eq([{"family"=>"Duncan", "given"=>""}])
      expect(extra[:event_csl]['title']).to eq("Web analytics: Numbers speak louder than words")
      expect(extra[:event_csl]['container-title']).to eq("O'Really?")
      expect(extra[:event_csl]['issued']).to eq("date-parts"=>[[2012, 5, 18]])
      expect(extra[:event_csl]['type']).to eq("post")
    end

    it "should report if there is one event returned by the ScienceSeeker API" do
      work = FactoryGirl.create(:work, doi: "10.1371/journal.pone.0035869", published_on: "2012-05-03")
      body = File.read(fixture_path + 'science_seeker_one.xml')
      result = Hash.from_xml(body)
      result.extend Hashie::Extensions::DeepFetch
      response = subject.parse_data(result, work)
      expect(response[:works].length).to eq(1)
      expect(response[:events][:total]).to eq(1)
      expect(response[:events][:events_url]).to eq("http://scienceseeker.org/posts/?filter0=citation&modifier0=doi&value0=#{work.doi_escaped}")
      expect(response[:events][:days].length).to eq(1)
      expect(response[:events][:days].first).to eq(year: 2012, month: 5, day: 18, total: 1)
      expect(response[:events][:months].length).to eq(1)
      expect(response[:events][:months].first).to eq(year: 2012, month: 5, total: 1)

      event = response[:works].first
      expect(event['URL']).to eq("http://duncan.hull.name/2012/05/18/two-ton/")
      expect(event['author']).to eq([{"family"=>"Duncan", "given"=>""}])
      expect(event['title']).to eq("Web analytics: Numbers speak louder than words")
      expect(event['container-title']).to eq("O'Really?")
      expect(event['issued']).to eq("date-parts"=>[[2012, 5, 18]])
      expect(event['type']).to eq("post")
      expect(event['related_works']).to eq([{"related_work"=>"doi:10.1371/journal.pone.0035869", "source"=>"scienceseeker", "relation_type"=>"discusses"}])

      extra = response[:events][:extra].first
      expect(extra[:event_time]).to eq("2012-05-18T07:58:34Z")
      expect(extra[:event_url]).to eq(extra[:event]['link']['href'])
      expect(extra[:event_csl]['author']).to eq([{"family"=>"Duncan", "given"=>""}])
      expect(extra[:event_csl]['title']).to eq("Web analytics: Numbers speak louder than words")
      expect(extra[:event_csl]['container-title']).to eq("O'Really?")
      expect(extra[:event_csl]['issued']).to eq("date-parts"=>[[2012, 5, 18]])
      expect(extra[:event_csl]['type']).to eq("post")
    end

    it "should catch timeout errors with the ScienceSeeker API" do
      work = FactoryGirl.create(:work, :doi => "10.2307/683422")
      result = { error: "the server responded with status 408 for http://scienceseeker.org/search/default/?type=post&filter0=citation&modifier0=doi&value0=#{work.doi_escaped}", status: 408 }
      response = subject.parse_data(result, work)
      expect(response).to eq(result)
    end
  end
end
