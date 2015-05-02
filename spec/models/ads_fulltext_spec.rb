require 'rails_helper'

describe AdsFulltext, type: :model, vcr: true do
  subject { FactoryGirl.create(:ads_fulltext) }

  let(:work) { FactoryGirl.create(:work, doi: "10.1371/journal.pmed.0020124") }

  context "get_data" do
    it "should report that there are no events if the doi and canonical_url are missing" do
      work = FactoryGirl.create(:work, doi: nil, canonical_url: nil)
      expect(subject.get_data(work)).to eq({})
    end

    it "should report if there are no events returned by the ADS API" do
      work = FactoryGirl.create(:work, doi: "10.1371/journal.pone.0122731")
      body = File.read(fixture_path + 'ads_fulltext_nil.json')
      stub = stub_request(:get, subject.get_query_url(work))
             .to_return(:body => body)
      response = subject.get_data(work)
      expect(response).to eq(JSON.parse(body))
      expect(stub).to have_been_requested
    end

    it "should report if there are events returned by the ADS API" do
      body = File.read(fixture_path + 'ads_fulltext.json')
      stub = stub_request(:get, subject.get_query_url(work))
             .to_return(:body => body)
      response = subject.get_data(work)
      expect(response).to eq(JSON.parse(body))
      expect(stub).to have_been_requested
    end

    it "should catch errors with the ADS API" do
      stub = stub_request(:get, subject.get_query_url(work)).to_return(:status => [408])
      response = subject.get_data(work, options = { :source_id => subject.id })
      expect(response).to eq(error: "the server responded with status 408 for https://api.adsabs.harvard.edu/v1/search/query?q=%22body%3A#{work.doi_escaped}%22&start=0&rows=100&fl=author%2Ctitle%2Cpubdate%2Cidentifier%2Cdoi", status: 408)
      expect(stub).to have_been_requested
      expect(Alert.count).to eq(1)
      alert = Alert.first
      expect(alert.class_name).to eq("Net::HTTPRequestTimeOut")
      expect(alert.status).to eq(408)
      expect(alert.source_id).to eq(subject.id)
    end
  end

  context "parse_data" do
    it "should report if there are no events returned by the ADS API" do
      body = File.read(fixture_path + 'ads_fulltext_nil.json')
      result = JSON.parse(body)
      expect(subject.parse_data(result, work)).to eq(works: [], events: { source: "ads_fulltext", work: work.pid, total: 0, events_url: nil })
    end

    it "should report if there are events returned by the ADS API" do
      work = FactoryGirl.create(:work, doi: "10.1371/journal.pmed.0020124", published_on: "2005-08-30")
      body = File.read(fixture_path + 'ads_fulltext.json')
      result = JSON.parse(body)
      response = subject.parse_data(result, work)
      expect(response[:works].length).to eq(3)
      expect(response[:events][:total]).to eq(3)
      expect(response[:events][:days]).to be_nil
      expect(response[:events][:months]).to be_nil

      event = response[:works].last
      expect(event['author']).to eq([{"family"=>"Lyons", "given"=>"Russell"}])
      expect(event['title']).to eq("The Spread of Evidence-Poor Medicine via Flawed Social-Network Analysis")
      expect(event['container-title']).to eq("ArXiV")
      expect(event['issued']).to eq("date-parts"=>[[2010, 7]])
      expect(event['type']).to eq("article-journal")
      expect(event['URL']).to eq("http://arxiv.org/abs/1007.2876")
      expect(event['type']).to eq("article-journal")
      expect(event['related_works']).to eq([{"related_work"=> work.pid, "source"=>"ads_fulltext", "relation_type"=>"cites"}])
    end
  end
end
