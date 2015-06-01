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
      response = subject.get_data(work, options = { :agent_id => subject.id })
      expect(response).to eq(error: "the server responded with status 408 for https://api.adsabs.harvard.edu/v1/search/query?q=%22body%3A#{work.doi_escaped}%22&start=0&rows=100&fl=author%2Ctitle%2Cpubdate%2Cidentifier%2Cdoi", status: 408)
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
      body = File.read(fixture_path + 'ads_fulltext_nil.json')
      result = JSON.parse(body)
      expect(subject.parse_data(result, work)).to eq(works: [], events: [{ source_id: "ads_fulltext", work_id: work.pid, total: 0, events_url: nil }])
    end

    it "should report if there are events returned by the ADS API" do
      work = FactoryGirl.create(:work, doi: "10.1371/journal.pmed.0020124", published_on: "2005-08-30")
      body = File.read(fixture_path + 'ads_fulltext.json')
      result = JSON.parse(body)
      response = subject.parse_data(result, work)

      event = response[:events].first
      expect(event[:source_id]).to eq("ads_fulltext")
      expect(event[:work_id]).to eq(work.pid)
      expect(event[:total]).to eq(3)
      expect(event[:days]).to be_nil
      expect(event[:months]).to be_nil

      expect(response[:works].length).to eq(3)
      related_work = response[:works].last
      expect(related_work['author']).to eq([{"family"=>"Lyons", "given"=>"Russell"}])
      expect(related_work['title']).to eq("The Spread of Evidence-Poor Medicine via Flawed Social-Network Analysis")
      expect(related_work['container-title']).to eq("ArXiV")
      expect(related_work['issued']).to eq("date-parts"=>[[2010, 7]])
      expect(related_work['type']).to eq("article-journal")
      expect(related_work['URL']).to eq("http://arxiv.org/abs/1007.2876")
      expect(related_work['type']).to eq("article-journal")
      expect(related_work['related_works']).to eq([{"related_work"=> work.pid, "source"=>"ads_fulltext", "relation_type"=>"cites"}])
    end
  end
end
