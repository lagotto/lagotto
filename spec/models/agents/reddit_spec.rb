require 'rails_helper'

describe Reddit, type: :model, vcr: true do
  subject { FactoryGirl.create(:reddit) }

  let(:work) { FactoryGirl.create(:work, pid: "http://doi.org/10.1371/journal.ppat.0008776", doi: "10.1371/journal.ppat.0008776", canonical_url: "http://www.plosone.org/article/info:doi/10.1371/journal.ppat.0008776") }

  context "get_data" do
    it "should report that there are no events if the doi and canonical_url are missing" do
      work = FactoryGirl.create(:work, doi: nil, canonical_url: nil)
      expect(subject.get_data(work_id: work.id)).to eq({})
    end

    it "should report if there are no events returned by the Reddit API" do
      work = FactoryGirl.create(:work, doi: "10.1371/journal.pone.0044294", canonical_url: "")
      response = subject.get_data(work_id: work.id)
      expect(response).to eq("kind"=>"Listing", "data"=>{"facets"=>{}, "modhash"=>"", "children"=>[], "after"=>nil, "before"=>nil})
    end

    it "should report if there are events returned by the Reddit API" do
      response = subject.get_data(work_id: work.id)
      expect(response).to eq("kind"=>"Listing", "data"=>{"facets"=>{}, "modhash"=>"", "children"=>[], "after"=>nil, "before"=>nil})
    end

    it "should catch errors with the Reddit API" do
      work = FactoryGirl.create(:work, :doi => "10.1371/journal.pone.0000001")
      stub = stub_request(:get, subject.get_query_url(work_id: work.id)).to_return(:status => [408])
      response = subject.get_data(work_id: work, source_id: subject.source_id)
      expect(response).to eq(error: "the server responded with status 408 for http://www.reddit.com/search.json?q=#{subject.get_query_string(work_id: work.id)}&limit=100", :status=>408)
      expect(stub).to have_been_requested
      expect(Notification.count).to eq(1)
      notification = Notification.first
      expect(notification.class_name).to eq("Net::HTTPRequestTimeOut")
      expect(notification.status).to eq(408)
    end
  end

  context "parse_data" do
    it "should report if the doi and canonical_url are missing" do
      work = FactoryGirl.create(:work, doi: nil, canonical_url: nil)
      result = {}
      result.extend Hashie::Extensions::DeepFetch
      expect(subject.parse_data(result, work_id: work.id)).to eq([])
    end

    it "should report if there are no events returned by the Reddit API" do
      work = FactoryGirl.create(:work, :doi => "10.1371/journal.pone.0044294")
      body = File.read(fixture_path + 'reddit_nil.json', encoding: 'UTF-8')
      result = JSON.parse(body)
      result.extend Hashie::Extensions::DeepFetch
      response = subject.parse_data(result, work_id: work.id)
      expect(response).to eq([])
    end

    it "should report if there are events returned by the Reddit API" do
      work = FactoryGirl.create(:work, :doi => "10.1371/journal.pone.0008776", published_on: "2013-05-03")
      body = File.read(fixture_path + 'reddit.json', encoding: 'UTF-8')
      result = JSON.parse(body)
      result.extend Hashie::Extensions::DeepFetch
      response = subject.parse_data(result, work_id: work.id)

      expect(response.length).to eq(4)
      expect(response.first[:relation]).to eq("subj_id"=>"http://www.reddit.com/r/askscience/comments/1ee560/askscience_ama_we_are_the_authors_of_a_recent/",
                                              "obj_id"=>work.pid,
                                              "relation_type_id"=>"discusses",
                                              "provenance_url"=>"http://www.reddit.com/search?q=%22#{work.doi}%22+OR+%22#{work.canonical_url}%22",
                                              "source_id"=>"reddit")
      expect(response.last[:relation]).to eq("subj_id"=>"https://www.reddit.com",
                                             "obj_id"=>work.pid,
                                             "relation_type_id"=>"likes",
                                             "total"=>1013,
                                             "provenance_url"=>"http://www.reddit.com/search?q=%22#{work.doi}%22+OR+%22#{work.canonical_url}%22",
                                             "source_id"=>"reddit")

      expect(response.first[:subj]).to eq("pid"=>"http://www.reddit.com/r/askscience/comments/1ee560/askscience_ama_we_are_the_authors_of_a_recent/",
                                          "author"=>[{"given"=>"jjberg2"}],
                                          "title"=>"AskScience AMA: We are the authors of a recent paper on genetic genealogy and relatedness among the people of Europe. Ask us anything about our paper!",
                                          "container-title"=>"Reddit",
                                          "issued"=>"2013-05-15T17:06:24Z",
                                          "URL"=>"http://www.reddit.com/r/askscience/comments/1ee560/askscience_ama_we_are_the_authors_of_a_recent/",
                                          "type"=>"personal_communication",
                                          "tracked"=>false,
                                          "registration_agency_id"=>"reddit")
    end

    it "should catch timeout errors with the Reddit API" do
      work = FactoryGirl.create(:work, :doi => "10.2307/683422")
      result = { error: "the server responded with status 408 for http://www.reddit.com/search.json?q=#{subject.get_query_string(work_id: work.id)}", status: 408 }
      response = subject.parse_data(result, work_id: work.id)
      expect(response).to eq([result])
    end
  end
end
