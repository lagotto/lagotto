require 'rails_helper'

describe ArticleCoverageCurated, type: :model, vcr: true do
  before(:each) { allow(Time.zone).to receive(:now).and_return(Time.mktime(2013, 9, 5)) }

  subject { FactoryGirl.create(:article_coverage_curated) }

  let(:work) { FactoryGirl.create(:work, :doi => "10.1371/journal.pone.0047712", published_on: "2013-11-01") }

  it "should report that there are no events if the doi is missing" do
    work = FactoryGirl.create(:work, :doi => nil)
    expect(subject.get_data(work)).to eq({})
  end

  it "should report that there are no events if the doi has the wrong prefix" do
    work = FactoryGirl.create(:work, :doi => "10.5194/acp-12-12021-2012")
    expect(subject.get_data(work)).to eq({})
  end

  context "get_data from the Article Coverage API" do
    it "should report if work doesn't exist in Article Coverage source" do
      work = FactoryGirl.create(:work, :doi => "10.1371/journal.pone.9008776")
      expect(subject.get_data(work)).to eq(error: "Article not found", status: 404)
    end

    it "should report if there are no events and event_count returned by the Article Coverage API" do
      work = FactoryGirl.create(:work, :doi => "10.1371/journal.pone.0008775")
      response = subject.get_data(work)
      expect(response).to eq(error: "Article not found", status: 404)
    end

    it "should report if there are events and event_count returned by the Article Coverage API" do
      response = subject.get_data(work)
      expect(response["doi"]).to eq(work.doi)
      expect(response["referrals"].length).to eq(1)
      referral = response["referrals"].first
      expect(referral["title"]).to eq("Everything You Know About Your Personal Hygiene Is Wrong ")
    end

    it "should catch timeout errors with the Article Coverage API" do
      stub = stub_request(:get, subject.get_query_url(work)).to_return(:status => [408])
      response = subject.get_data(work, options = { :source_id => subject.id })
      expect(response).to eq(error: "the server responded with status 408 for http://mediacuration.plos.org/api/v1?doi=#{work.doi_escaped}", :status=>408)
      expect(stub).to have_been_requested
      expect(Alert.count).to eq(1)
      alert = Alert.first
      expect(alert.class_name).to eq("Net::HTTPRequestTimeOut")
      expect(alert.status).to eq(408)
      expect(alert.source_id).to eq(subject.id)
    end
  end

  context "parse_data from the Article Coverage API" do
    it "should report if the doi is missing" do
      work = FactoryGirl.create(:work, :doi => nil)
      result = {}
      expect(subject.parse_data(result, work)).to eq(works: [], events: { source: "article_coverage_curated", work: work.pid, comments: 0, total: 0, days: [], months: [] })
    end

    it "should report if work doesn't exist in Article Coverage source" do
      result = { error: "Article not found", status: 404 }
      response = subject.parse_data(result, work)
      expect(response).to eq(works: [], events: { source: "article_coverage_curated", work: work.pid, comments: 0, total: 0, days: [], months: [] })
    end

    it "should report if there are no events and event_count returned by the Article Coverage API" do
      body = File.read(fixture_path + 'article_coverage_curated_nil.json')
      result = JSON.parse(body)
      response = subject.parse_data(result, work)
      expect(response).to eq(works: [], events: { source: "article_coverage_curated", work: work.pid, comments: 0, total: 0, days: [], months: [] })
    end

    it "should report if there are events and event_count returned by the Article Coverage API" do
      body = File.read(fixture_path + 'article_coverage_curated.json')
      result = JSON.parse(body)
      response = subject.parse_data(result, work)
      expect(response[:works].length).to eq(15)
      expect(response[:events][:total]).to eq(15)
      expect(response[:events][:comments]).to eq(15)
      expect(response[:events][:days].length).to eq(0)
      expect(response[:events][:months].length).to eq(1)
      expect(response[:events][:months].first).to eq(year: 2013, month: 11, total: 2, comments: 2)

      event = response[:works].second
      expect(event['URL']).to eq("http://www.huffingtonpost.com/2013/11/08/personal-hygiene-facts_n_4217839.html")
      expect(event['author']).to be_nil
      expect(event['title']).to eq("Everything You Know About Your Personal Hygiene Is Wrong")
      expect(event['container-title']).to eq("The Huffington Post")
      expect(event['issued']).to eq("date-parts"=>[[2013, 11, 20]])
      expect(event['timestamp']).to eq("2013-11-20T00:00:00Z")
      expect(event['type']).to eq("post")
      expect(event['related_works']).to eq([{"related_work"=>"doi:10.1371/journal.pone.0047712", "source"=>"article_coverage_curated", "relation_type"=>"discusses"}])
    end

    it "should catch timeout errors with the Article Coverage API" do
      result = { error: "the server responded with status 408 for http://example.org?doi=#{work.doi_escaped}", status: 408 }
      response = subject.parse_data(result, work)
      expect(response).to eq(result)
    end
  end
end
