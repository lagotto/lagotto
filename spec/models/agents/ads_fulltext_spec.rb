require 'rails_helper'

describe AdsFulltext, type: :model, vcr: true do
  subject { FactoryGirl.create(:ads_fulltext) }

  let(:work) { FactoryGirl.create(:work, doi: "10.1371/journal.pmed.0020124") }

  context "get_data" do
    it "should report that there are no events if the doi and canonical_url are missing" do
      work = FactoryGirl.create(:work, doi: nil, canonical_url: nil)
      expect(subject.get_data(work_id: work.id)).to eq({})
    end

    it "should report if there are no events returned by the ADS API" do
      work = FactoryGirl.create(:work, doi: "10.1371/journal.pone.0122731")
      body = File.read(fixture_path + 'ads_fulltext_nil.json')
      stub = stub_request(:get, subject.get_query_url(work_id: work))
             .to_return(:body => body)
      response = subject.get_data(work_id: work.id)
      expect(response).to eq(JSON.parse(body))
      expect(stub).to have_been_requested
    end

    it "should report if there are events returned by the ADS API" do
      body = File.read(fixture_path + 'ads_fulltext.json')
      stub = stub_request(:get, subject.get_query_url(work_id: work))
             .to_return(:body => body)
      response = subject.get_data(work_id: work.id)
      expect(response).to eq(JSON.parse(body))
      expect(stub).to have_been_requested
    end

    it "should catch errors with the ADS API" do
      stub = stub_request(:get, subject.get_query_url(work_id: work)).to_return(:status => [408])
      response = subject.get_data(work_id: work.id, source_id: subject.source_id)
      expect(response).to eq(error: "the server responded with status 408 for https://api.adsabs.harvard.edu/v1/search/query?q=%22body%3A#{work.doi_escaped}%22&start=0&rows=100&fl=author%2Ctitle%2Cpubdate%2Cidentifier%2Cdoi", status: 408)
      expect(stub).to have_been_requested
      expect(Notification.count).to eq(1)
      notification = Notification.first
      expect(notification.class_name).to eq("Net::HTTPRequestTimeOut")
      expect(notification.status).to eq(408)
      expect(notification.source_id).to eq(subject.source_id)
    end
  end

  context "parse_data" do
    it "should report if there are no events returned by the ADS API" do
      body = File.read(fixture_path + 'ads_fulltext_nil.json')
      result = JSON.parse(body)
      expect(subject.parse_data(result, work_id: work.id)).to eq([])
    end

    it "should report if there are events returned by the ADS API" do
      work = FactoryGirl.create(:work, doi: "10.1371/journal.pmed.0020124", published_on: "2005-08-30")
      body = File.read(fixture_path + 'ads_fulltext.json')
      result = JSON.parse(body)
      response = subject.parse_data(result, work_id: work.id)

      expect(response.length).to eq(3)

      expect(response.last[:relation]).to eq("subj_id" => "http://arxiv.org/abs/1007.2876",
                                             "obj_id" => work.pid,
                                             "relation_type_id" => "cites",
                                             "source_id" => "ads_fulltext")

      expect(response.last[:subj]).to include("pid" => "http://arxiv.org/abs/1007.2876",
                                              "author"=> ["family"=>"Lyons", "given"=>"Russell"],
                                              "title" => "The Spread of Evidence-Poor Medicine via Flawed Social-Network Analysis",
                                              "container-title" => "ArXiV",
                                              "issued" => { "date-parts" => [[2010, 7]] },
                                              "URL" => "http://arxiv.org/abs/1007.2876",
                                              "type" => "article-journal",
                                              "tracked" => false )
    end
  end
end
