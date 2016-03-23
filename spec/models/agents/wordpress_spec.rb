require 'rails_helper'

describe Wordpress, type: :model, vcr: true do
  subject { FactoryGirl.create(:wordpress) }

  let(:work) { FactoryGirl.create(:work, :doi => "10.1371/journal.pbio.1002020", canonical_url: "http://www.plosone.org/article/info:doi/10.1371/journal.pone.1002020", published_on: "2007-07-01") }

  context "urls" do
    it "should get_query_url" do
      expect(subject.get_query_url(work_id: work.id)).to eq("http://en.search.wordpress.com/?q=%22#{work.doi_escaped}%22&t=post&f=json&size=20")
    end

    it "should return empty hash if the doi and canonical_url are missing" do
      work = FactoryGirl.create(:work, :doi => nil, canonical_url: nil)
      expect(subject.get_query_url(work_id: work.id)).to eq({})
    end

    it "should return a query without doi if the doi is missing" do
      work = FactoryGirl.create(:work, :doi => nil)
      expect(subject.get_query_url(work_id: work.id)).to eq("http://en.search.wordpress.com/?q=#{subject.get_query_string(work_id: work.id)}&t=post&f=json&size=20")
    end

    it "should get_provenance_url" do
      expect(subject.get_provenance_url(work_id: work.id)).to eq("http://en.search.wordpress.com/?q=%22#{work.doi_escaped}%22&t=post")
    end
  end

  context "get_data" do
    it "should report that there are no events if the doi and canonical_url are missing" do
      work = FactoryGirl.create(:work, :doi => nil, canonical_url: nil)
      expect(subject.get_data(work_id: work.id)).to eq({})
    end

    it "should report if there are no events returned by the Wordpress API" do
      work = FactoryGirl.create(:work, :doi => "10.1371/journal.pone.0044294", canonical_url: "http://www.plosone.org/article/info:doi/10.1371/journal.pone.0044294")
      response = subject.get_data(work_id: work.id)
      expect(response).to eq("data"=>"null")
    end

    it "should report if there are events returned by the Wordpress API" do
      response = subject.get_data(work_id: work.id)
      expect(response["data"].length).to eq(2)
      data = response["data"].first
      expect(data["title"]).to eq("Are microbes vital on earth?")
    end

    it "should catch errors with the Wordpress API" do
      work = FactoryGirl.create(:work, doi: "10.1371/journal.pone.0000001", canonical_url: "http://www.plosone.org/article/info:doi/10.1371/journal.pone.0000001")
      stub = stub_request(:get, subject.get_query_url(work_id: work.id)).to_return(:status => [408])
      response = subject.get_data(work_id: work.id, source_id: subject.source_id)
      expect(response).to eq(error: "the server responded with status 408 for http://en.search.wordpress.com/?q=#{subject.get_query_string(work_id: work.id)}&t=post&f=json&size=20", :status=>408)
      expect(stub).to have_been_requested
      expect(Notification.count).to eq(1)
      notification = Notification.first
      expect(notification.class_name).to eq("Net::HTTPRequestTimeOut")
      expect(notification.status).to eq(408)
    end
  end

  context "parse_data" do
    it "should report that there are no events if the doi and canonical_url are missing" do
      work = FactoryGirl.create(:work, doi: nil, canonical_url: nil)
      result = {}
      response = subject.parse_data(result, work_id: work.id)
      expect(response).to eq([])
    end

    it "should report if there are no events returned by the Wordpress API" do
      work = FactoryGirl.create(:work, :doi => "10.1371/journal.pone.0044294")
      result = { 'data' => "null\n" }
      response = subject.parse_data(result, work_id: work.id)
      expect(response).to eq([])
    end

    it "should report if there are events returned by the Wordpress API" do
      body = File.read(fixture_path + 'wordpress.json', encoding: 'UTF-8')
      result = { 'data' => JSON.parse(body) }
      response = subject.parse_data(result, work_id: work.id)

      expect(response.length).to eq(10)
      expect(response.first[:relation]).to eq("subj_id"=>"http://researchremix.wordpress.com/2007/07/12/presentation-on-citation-rate-for-shared-data/",
                                              "obj_id"=>work.pid,
                                              "relation_type_id"=>"discusses",
                                              "provenance_url"=>"http://en.search.wordpress.com/?q=%2210.1371%2Fjournal.pbio.1002020%22&t=post",
                                              "source_id"=>"wordpress")

      expect(response.first[:subj]).to eq("pid"=>"http://researchremix.wordpress.com/2007/07/12/presentation-on-citation-rate-for-shared-data/",
                                          "author"=>[{"family"=>"Piwowar", "given"=>"Heather"}],
                                          "title"=>"Presentation on Citation Rate for Shared Data",
                                          "container-title"=>nil,
                                          "issued"=>"2007-07-12T15:36:38Z",
                                          "URL"=>"http://researchremix.wordpress.com/2007/07/12/presentation-on-citation-rate-for-shared-data/",
                                          "type"=>"post",
                                          "tracked"=>true)
    end

    it "should catch timeout errors with the Wordpress API" do
      work = FactoryGirl.create(:work, :doi => "10.2307/683422")
      result = { error: "the server responded with status 408 for http://en.search.wordpress.com/?q=\"#{work.doi_escaped}\"&t=post&f=json&size=20", status: 408 }
      response = subject.parse_data(result, work_id: work.id)
      expect(response).to eq([result])
    end
  end
end
