require 'rails_helper'

describe Nature, type: :model, vcr: true do
  subject { FactoryGirl.create(:nature) }

  let(:work) { FactoryGirl.build(:work, doi: "10.1371/journal.pone.0008776", published_on: "2009-09-01") }

  context "get_data" do
    it "should report that there are no events if the doi is missing" do
      work = FactoryGirl.build(:work, doi: nil)
      expect(subject.get_data(work)).to eq({})
    end

    it "should report if there are no events returned by the Nature Blogs API" do
      response = subject.get_data(work)
      expect(response).to eq('data' => [])
    end

    it "should report if there are events returned by the Nature Blogs API" do
      work = FactoryGirl.build(:work, doi: "10.1371/journal.pone.0035869")
      response = subject.get_data(work)
      expect(response["data"].length).to eq(4)
      data = response["data"].first
      expect(data["post"]["title"]).to eq("Research Blogging in PLos ONE")
    end

    it "should catch timeout errors with the Nature Blogs API" do
      work = FactoryGirl.build(:work, :doi => "10.1371/journal.pone.0000001")
      stub = stub_request(:get, subject.get_query_url(work)).to_return(:status => [408])
      response = subject.get_data(work, options = { :source_id => subject.id })
      expect(response).to eq(error: "the server responded with status 408 for http://blogs.nature.com/posts.json?doi=#{work.doi_escaped}", :status=>408)
      expect(stub).to have_been_requested
      expect(Alert.count).to eq(1)
      alert = Alert.first
      expect(alert.class_name).to eq("Net::HTTPRequestTimeOut")
      expect(alert.status).to eq(408)
      expect(alert.source_id).to eq(subject.id)
    end
  end

  context "parse_data" do
    let(:null_response) { { events: [], :events_by_day=>[], :events_by_month=>[], :events_url=>nil, total: 0, event_metrics: { pdf: nil, html: nil, shares: nil, groups: nil, comments: nil, likes: nil, citations: 0, total: 0 }, :extra=>nil } }

    it "should report if the doi is missing" do
      work = FactoryGirl.build(:work, :doi => nil)
      result = {}
      expect(subject.parse_data(result, work)).to eq(null_response)
    end

    it "should report if there are no events returned by the Nature Blogs API" do
      body = File.read(fixture_path + 'nature_nil.json')
      result = { 'data' => JSON.parse(body) }
      response = subject.parse_data(result, work)
      expect(response).to eq(null_response)
    end

    it "should report if there are events returned by the Nature Blogs API" do
      body = File.read(fixture_path + 'nature.json')
      result = { 'data' => JSON.parse(body) }
      response = subject.parse_data(result, work)
      expect(response[:total]).to eq(10)

      expect(response[:events_by_day].length).to eq(1)
      expect(response[:events_by_day].first).to eq(year: 2009, month: 9, day: 18, total: 1)
      expect(response[:events_by_month].length).to eq(9)
      expect(response[:events_by_month].first).to eq(year: 2009, month: 9, total: 1)

      event = response[:events].first
      expect(event['URL']).to eq("http://bjoern.brembs.net/news.php?item.854.5")
      expect(event['author']).to be_nil
      expect(event['title']).to eq("More Impact Factor spam from Nature")
      expect(event['container-title']).to eq("bjoern.brembs.blog : a neuroscientist's blog")
      expect(event['issued']).to eq("date-parts"=>[[2012, 6, 19]])
      expect(event['type']).to eq("post")
    end

    it "should catch timeout errors with the Nature Blogs APi" do
      work = FactoryGirl.create(:work, :doi => "10.1371/journal.pone.0000001")
      result = { error: "the server responded with status 408 for http://blogs.nature.com/posts.json?doi=#{work.doi_escaped}", status: 408 }
      response = subject.parse_data(result, work)
      expect(response).to eq(result)
    end
  end
end
