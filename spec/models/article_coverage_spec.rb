require 'rails_helper'

describe ArticleCoverage, type: :model, vcr: true do
  subject { FactoryGirl.create(:article_coverage) }

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
      work = FactoryGirl.create(:work, :doi => "10.1371/journal.pone.0008776")
      expect(subject.get_data(work)).to eq(error: "Article not found", status: 404)
    end

    it "should report if there are no events returned by the Article Coverage API" do
      work = FactoryGirl.create(:work, :doi => "10.1371/journal.pone.0008775")
      response = subject.get_data(work)
      expect(subject.get_data(work)).to eq(error: "Article not found", status: 404)
    end

    it "should report if there are events returned by the Article Coverage API" do
      response = subject.get_data(work)
      expect(response["doi"]).to eq(work.doi)
      expect(response["referrals"].length).to eq(9)
      referral = response["referrals"].first
      expect(referral["title"]).to eq("Everything You Know About Your Personal Hygiene Is Wrong ")
    end

    it "should catch timeout errors with the Article Coverage API" do
      stub = stub_request(:get, subject.get_query_url(work)).to_return(:status => [408])
      response = subject.get_data(work, options = { :source_id => subject.id })
      expect(response).to eq(error: "the server responded with status 408 for http://mediacuration.plos.org/api/v1?doi=#{work.doi_escaped}&state=all", :status=>408)
      expect(stub).to have_been_requested
      expect(Alert.count).to eq(1)
      alert = Alert.first
      expect(alert.class_name).to eq("Net::HTTPRequestTimeout")
      expect(alert.status).to eq(408)
      expect(alert.source_id).to eq(subject.id)
    end
  end

  context "parse_data from the Article Coverage API" do
    it "should report if the doi is missing" do
      work = FactoryGirl.create(:work, :doi => nil)
      result = {}
      expect(subject.parse_data(result, work)).to eq(events: { source: "article_coverage", work: work.pid, comments: 0, total: 0, extra: [] })
    end

    it "should report if work doesn't exist in Article Coverage source" do
      result = { error: "{\"error\":\"Work not found\"}" }
      response = subject.parse_data(result, work)
      expect(response).to eq(result)
    end

    it "should report if there are no events returned by the Article Coverage API" do
      body = File.read(fixture_path + 'article_coverage_curated_nil.json')
      result = JSON.parse(body)
      response = subject.parse_data(result, work)
      expect(response).to eq(events: { source: "article_coverage", work: work.pid, comments: 0, total: 0, extra: [] })
    end

    it "should report if there are events returned by the Article Coverage API" do
      body = File.read(fixture_path + 'article_coverage.json')
      result = JSON.parse(body)
      response = subject.parse_data(result, work)
      expect(response[:events][:total]).to eq(2)
      expect(response[:events][:comments]).to eq(2)

      extra = response[:events][:extra].first
      expect(extra[:event_time]).to eq("2013-11-20T00:00:00Z")
      expect(extra[:event_url]).to eq("http://www.huffingtonpost.com/2013/11/08/personal-hygiene-facts_n_4217839.html")

      event_data = extra[:event]
      expect(event_data['referral']).to eq("http://www.huffingtonpost.com/2013/11/08/personal-hygiene-facts_n_4217839.html")
      expect(event_data['language']).to eq("English")
      expect(event_data['title']).to eq("Everything You Know About Your Personal Hygiene Is Wrong")
      expect(event_data['type']).to eq("Blog")
      expect(event_data['publication']).to eq("The Huffington Post")
      expect(event_data['published_on']).to eq("2013-11-20T00:00:00Z")
      expect(event_data['link_state']).to eq("APPROVED")
    end

    it "should catch timeout errors with the Article Coverage API" do
      result = { error: "the server responded with status 408 for http://example.org?doi=#{work.doi_escaped}", status: 408 }
      response = subject.parse_data(result, work)
      expect(response).to eq(result)
    end
  end
end
