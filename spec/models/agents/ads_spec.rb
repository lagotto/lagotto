require 'rails_helper'

describe Ads, type: :model, vcr: true do
  subject { FactoryGirl.create(:ads) }

  let(:work) { FactoryGirl.create(:work, doi: "10.1371/journal.pone.0118494") }

  context "get_data" do
    it "should report that there are no events if the doi and canonical_url are missing" do
      work = FactoryGirl.create(:work, doi: nil, canonical_url: nil)
      expect(subject.get_data(work_id: work.id)).to eq({})
    end

    it "should report if there are no events returned by the ADS API" do
      work = FactoryGirl.create(:work, doi: "10.1371/journal.pmed.0020124")
      body = File.read(fixture_path + 'ads_nil.json')
      stub = stub_request(:get, subject.get_query_url(work_id: work))
             .to_return(:body => body)
      response = subject.get_data(work_id: work.id)
      expect(response).to eq(JSON.parse(body))
      expect(stub).to have_been_requested
    end

    it "should report if there are events returned by the ADS API" do
      body = File.read(fixture_path + 'ads.json')
      stub = stub_request(:get, subject.get_query_url(work_id: work))
             .to_return(:body => body)
      response = subject.get_data(work_id: work.id)
      expect(response).to eq(JSON.parse(body))
      expect(stub).to have_been_requested
    end

    it "should catch errors with the ADS API" do
      stub = stub_request(:get, subject.get_query_url(work_id: work)).to_return(:status => [408])
      response = subject.get_data(work_id: work.id, agent_id: subject.id)
      expect(response).to eq(error: "the server responded with status 408 for https://api.adsabs.harvard.edu/v1/search/query?q=%22doi%3A#{work.doi_escaped}%22&start=0&rows=100&fl=author%2Ctitle%2Cpubdate%2Cidentifier%2Cdoi", :status=>408)
      expect(stub).to have_been_requested
      expect(Notification.count).to eq(1)
      notification = Notification.first
      expect(notification.class_name).to eq("Net::HTTPRequestTimeOut")
      expect(notification.status).to eq(408)
      expect(notification.agent_id).to eq(subject.id)
    end
  end

  context "parse_data" do
    it "should report if there are no events returned by the ADS API" do
      body = File.read(fixture_path + 'ads_nil.json')
      result = JSON.parse(body)
      expect(subject.parse_data(result, work_id: work.id)).to eq([])
    end

    it "should report if there are events returned by the ADS API" do
      work = FactoryGirl.create(:work, doi: "10.1371/journal.pone.0118494", published_on: "2015-03-04")
      body = File.read(fixture_path + 'ads.json')
      result = JSON.parse(body)
      response = subject.parse_data(result, work_id: work.id)

      expect(response.length).to eq(1)

      expect(response.first[:relation]).to eq("subject" => "http://arxiv.org/abs/1503.04201",
                                              "object" => work.pid,
                                              "relation_type_id" => "is_previous_version_of",
                                              "source_id" => "ads")

      expect(response.first[:work]).to eq("pid" => "http://arxiv.org/abs/1503.04201",
                                          "author"=> [{ "family"=>"Hippel", "given"=>"Ted"},
                                                      { "family"=>"Hippel", "given"=>"Courtney" }],
                                          "title" => "To Apply or Not to Apply: A Survey Analysis of Grant Writing Costs and Benefits",
                                          "container-title" => "ArXiV",
                                          "issued" => { "date-parts" => [[2015, 3]] },
                                          "URL" => "http://arxiv.org/abs/1503.04201",
                                          "arxiv" => "1503.04201",
                                          "type" => "article-journal",
                                          "tracked" => false)
    end
  end
end
