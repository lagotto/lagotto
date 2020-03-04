require 'rails_helper'

describe Ads, type: :model, vcr: true do
  subject { FactoryGirl.create(:ads) }

  let(:work) { FactoryGirl.create(:work, doi: "10.1371/journal.pone.0118494") }

  context "get_data" do
    it "should report that there are no events if the doi and canonical_url are missing" do
      work = FactoryGirl.create(:work, doi: nil, canonical_url: nil)
      expect(subject.get_data(work)).to eq({})
    end

    it "should report if there are no events returned by the ADS API" do
      work = FactoryGirl.create(:work, doi: "10.1371/journal.pmed.0020124")
      body = File.read(fixture_path + 'ads_nil.json')
      stub = stub_request(:get, subject.get_query_url(work))
             .to_return(:body => body)
      response = subject.get_data(work)
      expect(response).to eq(JSON.parse(body))
      expect(stub).to have_been_requested
    end

    it "should report if there are events returned by the ADS API" do
      body = File.read(fixture_path + 'ads.json')
      stub = stub_request(:get, subject.get_query_url(work))
             .to_return(:body => body)
      response = subject.get_data(work)
      expect(response).to eq(JSON.parse(body))
      expect(stub).to have_been_requested
    end

    it "should catch errors with the ADS API" do
      stub = stub_request(:get, subject.get_query_url(work)).to_return(:status => [408])
      response = subject.get_data(work, options = { :source_id => subject.id })
      expect(response).to eq(error: "the server responded with status 408 for https://api.adsabs.harvard.edu/v1/search/query?q=%22doi%3A#{work.doi_escaped}%22&start=0&rows=100&fl=author%2Ctitle%2Cpubdate%2Cidentifier%2Cdoi", :status=>408)
      expect(stub).to have_been_requested
      expect(Alert.count).to eq(1)
      alert = Alert.first
      expect(alert.class_name).to eq("Net::HTTPRequestTimeout")
      expect(alert.status).to eq(408)
      expect(alert.source_id).to eq(subject.id)
    end
  end

  context "parse_data" do
    it "should report if there are no events returned by the ADS API" do
      body = File.read(fixture_path + 'ads_nil.json')
      result = JSON.parse(body)
      expect(subject.parse_data(result, work)).to eq(works: [], events: { source: "ads", work: work.pid, total: 0, events_url: nil })
    end

    it "should report if there are events returned by the ADS API" do
      work = FactoryGirl.create(:work, doi: "10.1371/journal.pone.0118494", published_on: "2015-03-04")
      body = File.read(fixture_path + 'ads.json')
      result = JSON.parse(body)
      response = subject.parse_data(result, work)
      expect(response[:works].length).to eq(1)
      expect(response[:events][:total]).to eq(1)
      expect(response[:events][:days]).to be_nil
      expect(response[:events][:months]).to be_nil

      event = response[:works].last
      expect(event['author']).to eq([{"family"=>"Von Hippel", "given"=>"Ted"}, {"family"=>"Von Hippel", "given"=>"Courtney"}])
      expect(event['title']).to eq("To Apply or Not to Apply: A Survey Analysis of Grant Writing Costs and Benefits")
      expect(event['container-title']).to eq("ArXiV")
      expect(event['issued']).to eq("date-parts"=>[[2015, 3]])
      expect(event['type']).to eq("article-journal")
      expect(event['URL']).to eq("http://arxiv.org/abs/1503.04201")
      expect(event['type']).to eq("article-journal")
      expect(event['related_works']).to eq([{"related_work"=> work.pid, "source"=>"ads", "relation_type"=>"is_previous_version_of"}])
    end
  end
end
