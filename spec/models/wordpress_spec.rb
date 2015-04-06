require 'rails_helper'

describe Wordpress, type: :model, vcr: true do
  subject { FactoryGirl.create(:wordpress) }

  let(:work) { FactoryGirl.create(:work, :doi => "10.1371/journal.pbio.1002020", canonical_url: "http://www.plosone.org/article/info:doi/10.1371/journal.pone.1002020", published_on: "2007-07-01") }

  context "query_url" do
    it "should return empty hash if the doi and canonical_url are missing" do
      work = FactoryGirl.create(:work, :doi => nil, canonical_url: nil)
      expect(subject.get_query_url(work)).to eq({})
    end

    it "should return a query without doi if the doi is missing" do
      work = FactoryGirl.create(:work, :doi => nil)
      expect(subject.get_query_url(work)).to eq("http://en.search.wordpress.com/?q=#{subject.get_query_string(work)}&t=post&f=json&size=20")
    end
  end

  context "get_data" do
    it "should report that there are no events if the doi and canonical_url are missing" do
      work = FactoryGirl.create(:work, :doi => nil, canonical_url: nil)
      expect(subject.get_data(work)).to eq({})
    end

    it "should report if there are no events returned by the Wordpress API" do
      work = FactoryGirl.create(:work, :doi => "10.1371/journal.pone.0044294", canonical_url: "http://www.plosone.org/article/info:doi/10.1371/journal.pone.0044294")
      response = subject.get_data(work)
      expect(response).to eq("data"=>"null")
    end

    it "should report if there are events returned by the Wordpress API" do
      response = subject.get_data(work)
      expect(response["data"].length).to eq(1)
      data = response["data"].first
      expect(data["title"]).to eq("Are microbes vital on earth?")
    end

    it "should catch errors with the Wordpress API" do
      work = FactoryGirl.create(:work, doi: "10.1371/journal.pone.0000001", canonical_url: "http://www.plosone.org/article/info:doi/10.1371/journal.pone.0000001")
      stub = stub_request(:get, subject.get_query_url(work)).to_return(:status => [408])
      response = subject.get_data(work, options = { :source_id => subject.id })
      expect(response).to eq(error: "the server responded with status 408 for http://en.search.wordpress.com/?q=#{subject.get_query_string(work)}&t=post&f=json&size=20", :status=>408)
      expect(stub).to have_been_requested
      expect(Alert.count).to eq(1)
      alert = Alert.first
      expect(alert.class_name).to eq("Net::HTTPRequestTimeOut")
      expect(alert.status).to eq(408)
      expect(alert.source_id).to eq(subject.id)
    end
  end

  context "parse_data" do
    it "should report that there are no events if the doi and canonical_url are missing" do
      work = FactoryGirl.create(:work, doi: nil, canonical_url: nil)
      result = {}
      response = subject.parse_data(result, work)
      expect(response).to eq(works: [], metrics: { source: "wordpress", work: work.pid, total: 0, days: [], months: [] })
    end

    it "should report if there are no events returned by the Wordpress API" do
      work = FactoryGirl.create(:work, :doi => "10.1371/journal.pone.0044294")
      result = { 'data' => "null\n" }
      response = subject.parse_data(result, work)
      expect(response).to eq(works: [], metrics: { source: "wordpress", work: work.pid, total: 0, days: [], months: [] })
    end

    it "should report if there are events returned by the Wordpress API" do
      body = File.read(fixture_path + 'wordpress.json', encoding: 'UTF-8')
      result = { 'data' => JSON.parse(body) }
      response = subject.parse_data(result, work)
      expect(response[:works].length).to eq(10)
      expect(response[:metrics][:total]).to eq(10)
      expect(response[:metrics][:events_url]).to eq("http://en.search.wordpress.com/?q=#{subject.get_query_string(work)}&t=post")
      expect(response[:metrics][:days].length).to eq(6)
      expect(response[:metrics][:days].first).to eq(year: 2007, month: 7, day: 12, total: 1)
      expect(response[:metrics][:months].length).to eq(6)
      expect(response[:metrics][:months].first).to eq(year: 2007, month: 7, total: 1)

      event = response[:works].first
      expect(event['URL']).to eq("http://researchremix.wordpress.com/2007/07/12/presentation-on-citation-rate-for-shared-data/")
      expect(event['author']).to eq([{"family"=>"Piwowar", "given"=>"Heather"}])
      expect(event['title']).to eq("Presentation on Citation Rate for Shared Data")
      expect(event['container-title']).to be_nil
      expect(event['issued']).to eq("date-parts"=>[[2007, 7, 12]])
      expect(event['type']).to eq("post")
    end

    it "should catch timeout errors with the Wordpress API" do
      work = FactoryGirl.create(:work, :doi => "10.2307/683422")
      result = { error: "the server responded with status 408 for http://en.search.wordpress.com/?q=\"#{work.doi_escaped}\"&t=post&f=json&size=20", status: 408 }
      response = subject.parse_data(result, work)
      expect(response).to eq(result)
    end
  end
end
