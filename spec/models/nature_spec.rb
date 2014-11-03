require 'rails_helper'

describe Nature, :type => :model do
  subject { FactoryGirl.create(:nature) }

  let(:article) { FactoryGirl.build(:article, doi: "10.1371/journal.pone.0008776", published_on: "2009-09-01") }

  context "get_data" do
    it "should report that there are no events if the doi is missing" do
      article = FactoryGirl.build(:article, :doi => nil)
      expect(subject.get_data(article)).to eq({})
    end

    it "should report if there are no events and event_count returned by the Nature Blogs API" do
      article = FactoryGirl.build(:article, :doi => "10.1371/journal.pone.0044294")
      body = File.read(fixture_path + 'nature_nil.json')
      stub = stub_request(:get, subject.get_query_url(article)).to_return(:body => body)
      response = subject.get_data(article)
      expect(response).to eq('data' => JSON.parse(body))
      expect(stub).to have_been_requested
    end

    it "should report if there are events and event_count returned by the Nature Blogs API" do
      body = File.read(fixture_path + 'nature.json')
      stub = stub_request(:get, subject.get_query_url(article)).to_return(:body => body)
      response = subject.get_data(article)
      expect(response).to eq('data' => JSON.parse(body))
      expect(stub).to have_been_requested
    end

    it "should catch timeout errors with the Nature Blogs API" do
      article = FactoryGirl.build(:article, :doi => "10.1371/journal.pone.0000001")
      stub = stub_request(:get, subject.get_query_url(article)).to_return(:status => [408])
      response = subject.get_data(article, options = { :source_id => subject.id })
      expect(response).to eq(error: "the server responded with status 408 for http://blogs.nature.com/posts.json?doi=#{article.doi_escaped}", :status=>408)
      expect(stub).to have_been_requested
      expect(Alert.count).to eq(1)
      alert = Alert.first
      expect(alert.class_name).to eq("Net::HTTPRequestTimeOut")
      expect(alert.status).to eq(408)
      expect(alert.source_id).to eq(subject.id)
    end
  end

  context "parse_data" do
    let(:null_response) { { events: [], :events_by_day=>[], :events_by_month=>[], :events_url=>nil, event_count: 0, event_metrics: { pdf: nil, html: nil, shares: nil, groups: nil, comments: nil, likes: nil, citations: 0, total: 0 } } }

    it "should report if the doi is missing" do
      article = FactoryGirl.build(:article, :doi => nil)
      result = {}
      expect(subject.parse_data(result, article)).to eq(null_response)
    end

    it "should report if there are no events and event_count returned by the Nature Blogs API" do
      body = File.read(fixture_path + 'nature_nil.json')
      result = { 'data' => JSON.parse(body) }
      response = subject.parse_data(result, article)
      expect(response).to eq(null_response)
    end

    it "should report if there are events and event_count returned by the Nature Blogs API" do
      body = File.read(fixture_path + 'nature.json')
      result = { 'data' => JSON.parse(body) }
      response = subject.parse_data(result, article)
      expect(response[:event_count]).to eq(10)

      expect(response[:events_by_day].length).to eq(1)
      expect(response[:events_by_day].first).to eq(year: 2009, month: 9, day: 18, total: 1)
      expect(response[:events_by_month].length).to eq(9)
      expect(response[:events_by_month].first).to eq(year: 2009, month: 9, total: 1)

      event = response[:events].first

      expect(event[:event_csl]['author']).to eq("")
      expect(event[:event_csl]['title']).to eq("More Impact Factor spam from Nature")
      expect(event[:event_csl]['container-title']).to eq("bjoern.brembs.blog : a neuroscientist's blog")
      expect(event[:event_csl]['issued']).to eq("date-parts"=>[[2012, 6, 19]])
      expect(event[:event_csl]['type']).to eq("post")

      expect(event[:event_time]).to eq("2012-06-19T16:40:23Z")
      expect(event[:event_url]).not_to be_nil
    end

    it "should catch timeout errors with the Nature Blogs APi" do
      article = FactoryGirl.create(:article, :doi => "10.1371/journal.pone.0000001")
      result = { error: "the server responded with status 408 for http://blogs.nature.com/posts.json?doi=#{article.doi_escaped}", status: 408 }
      response = subject.parse_data(result, article)
      expect(response).to eq(result)
    end
  end
end
