require 'rails_helper'

describe ArticleCoverageCurated, type: :model, vcr: true do
  before(:each) { allow(Time.zone).to receive(:now).and_return(Time.mktime(2013, 9, 5)) }

  subject { FactoryGirl.create(:article_coverage_curated) }

  let(:work) { FactoryGirl.create(:work, :doi => "10.1371/journal.pone.0047712", published_on: "2013-11-01") }

  it "should report that there are no events if the doi is missing" do
    work = FactoryGirl.create(:work, :doi => nil)
    expect(subject.get_data(work_id: work.id)).to eq({})
  end

  it "should report that there are no events if the doi has the wrong prefix" do
    work = FactoryGirl.create(:work, :doi => "10.5194/acp-12-12021-2012")
    expect(subject.get_data(work_id: work.id)).to eq({})
  end

  context "get_data from the Article Coverage API" do
    it "should report if work doesn't exist in Article Coverage source" do
      work = FactoryGirl.create(:work, :doi => "10.1371/journal.pone.9008776")
      expect(subject.get_data(work_id: work.id)).to eq(error: "Article not found", status: 404)
    end

    it "should report if there are no events and event_count returned by the Article Coverage API" do
      work = FactoryGirl.create(:work, :doi => "10.1371/journal.pone.0008775")
      expect(subject.get_data(work_id: work.id)).to eq(error: "Article not found", status: 404)
    end

    it "should report if there are events and event_count returned by the Article Coverage API" do
      response = subject.get_data(work_id: work.id)
      expect(response["doi"]).to eq(work.doi)
      expect(response["referrals"].length).to eq(1)
      referral = response["referrals"].first
      expect(referral["title"]).to eq("Everything You Know About Your Personal Hygiene Is Wrong ")
    end

    it "should catch timeout errors with the Article Coverage API" do
      stub = stub_request(:get, subject.get_query_url(work_id: work.id)).to_return(:status => [408])
      response = subject.get_data(work_id: work.id, source_id: subject.source_id)
      expect(response).to eq(error: "the server responded with status 408 for http://mediacuration.plos.org/api/v1?doi=#{work.doi_escaped}", :status=>408)
      expect(stub).to have_been_requested
      expect(Notification.count).to eq(1)
      notification = Notification.first
      expect(notification.class_name).to eq("Net::HTTPRequestTimeOut")
      expect(notification.status).to eq(408)
    end
  end

  context "parse_data from the Article Coverage API" do
    it "should report if the doi is missing" do
      work = FactoryGirl.create(:work, :doi => nil)
      result = {}
      expect(subject.parse_data(result, work_id: work.id)).to eq([])
    end

    it "should report if work doesn't exist in Article Coverage source" do
      result = { error: "Article not found", status: 404 }
      expect(subject.parse_data(result, work_id: work.id)).to eq([])
    end

    it "should report if there are no events and event_count returned by the Article Coverage API" do
      body = File.read(fixture_path + 'article_coverage_curated_nil.json')
      result = JSON.parse(body)
      expect(subject.parse_data(result, work_id: work.id)).to eq([])
    end

    it "should report if there are events and event_count returned by the Article Coverage API" do
      body = File.read(fixture_path + 'article_coverage_curated.json')
      result = JSON.parse(body)
      response = subject.parse_data(result, work_id: work.id)

      expect(response.length).to eq(15)
      expect(response.second[:relation]).to eq("subj_id"=>"http://www.huffingtonpost.com/2013/11/08/personal-hygiene-facts_n_4217839.html",
                                               "obj_id"=>work.pid,
                                               "relation_type_id"=>"discusses",
                                               "source_id"=>"article_coverage_curated")

      expect(response.second[:subj]).to eq("pid"=>"http://www.huffingtonpost.com/2013/11/08/personal-hygiene-facts_n_4217839.html",
                                           "author"=>nil,
                                           "title"=>"Everything You Know About Your Personal Hygiene Is Wrong",
                                           "container-title"=>"The Huffington Post",
                                           "issued"=>"2013-11-20T00:00:00Z",
                                           "URL"=>"http://www.huffingtonpost.com/2013/11/08/personal-hygiene-facts_n_4217839.html",
                                           "type"=>"post",
                                           "tracked"=>false)
    end

    it "should catch timeout errors with the Article Coverage API" do
      result = { error: "the server responded with status 408 for http://example.org?doi=#{work.doi_escaped}", status: 408 }
      response = subject.parse_data(result, work_id: work.id)
      expect(response).to eq([result])
    end
  end
end
