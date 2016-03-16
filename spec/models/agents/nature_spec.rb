require 'rails_helper'

describe Nature, type: :model, vcr: true do
  subject { FactoryGirl.create(:nature) }

  let(:work) { FactoryGirl.create(:work, doi: "10.1371/journal.pone.0008776", published_on: "2009-09-01") }

  context "urls" do
    it "should get_query_url" do
      expect(subject.get_query_url(work_id: work.id)).to eq("http://blogs.nature.com/posts.json?doi=#{work.doi_escaped}")
    end

    it "should return empty hash if the doi is missing" do
      work = FactoryGirl.create(:work, doi: nil)
      expect(subject.get_query_url(work_id: work.id)).to eq({})
    end
  end

  context "get_data" do
    it "should report that there are no events if the doi is missing" do
      work = FactoryGirl.create(:work, doi: nil)
      expect(subject.get_data(work_id: work.id)).to eq({})
    end

    it "should report if there are no events returned by the Nature Blogs API" do
      response = subject.get_data(work_id: work.id)
      expect(response).to eq("data"=>[])
    end

    it "should report if there are events returned by the Nature Blogs API" do
      work = FactoryGirl.create(:work, doi: "10.1371/journal.pone.0035869")
      response = subject.get_data(work_id: work.id)
      expect(response["data"].length).to eq(4)
      data = response["data"].first
      expect(data["post"]["title"]).to eq("Research Blogging in PLos ONE")
    end

    it "should catch timeout errors with the Nature Blogs API" do
      work = FactoryGirl.create(:work, :doi => "10.1371/journal.pone.0000001")
      stub = stub_request(:get, subject.get_query_url(work_id: work.id)).to_return(:status => [408])
      response = subject.get_data(work_id: work, agent_id: subject.id)
      expect(response).to eq(error: "the server responded with status 408 for http://blogs.nature.com/posts.json?doi=#{work.doi_escaped}", :status=>408)
      expect(stub).to have_been_requested
      expect(Notification.count).to eq(1)
      notification = Notification.first
      expect(notification.class_name).to eq("Net::HTTPRequestTimeOut")
      expect(notification.status).to eq(408)
      expect(notification.agent_id).to eq(subject.id)
    end
  end

  context "parse_data" do
    it "should report if the doi is missing" do
      work = FactoryGirl.create(:work, :doi => nil)
      result = {}
      expect(subject.parse_data(result, work_id: work.id)).to eq([])
    end

    it "should report if there are no events returned by the Nature Blogs API" do
      body = File.read(fixture_path + 'nature_nil.json')
      result = { 'data' => JSON.parse(body) }
      response = subject.parse_data(result, work_id: work.id)
      expect(response).to eq([])
    end

    it "should report if there are events returned by the Nature Blogs API" do
      body = File.read(fixture_path + 'nature.json')
      result = { 'data' => JSON.parse(body) }
      response = subject.parse_data(result, work_id: work.id)

      expect(response.length).to eq(10)
      expect(response.first[:relation]).to eq("subj_id"=>"http://bjoern.brembs.net/news.php?item.854.5",
                                              "obj_id"=>work.pid,
                                              "relation_type_id"=>"discusses",
                                              "source_id"=>"nature")

      expect(response.first[:subj]).to eq("pid"=>"http://bjoern.brembs.net/news.php?item.854.5",
                                          "author"=>nil,
                                          "title"=>"More Impact Factor spam from Nature",
                                          "container-title"=>"bjoern.brembs.blog : a neuroscientist's blog",
                                          "issued"=>"2012-06-19T16:40:23Z",
                                          "URL"=>"http://bjoern.brembs.net/news.php?item.854.5",
                                          "type"=>"post",
                                          "tracked"=>true)
    end

    it "should catch timeout errors with the Nature Blogs API" do
      work = FactoryGirl.create(:work, :doi => "10.1371/journal.pone.0000001")
      result = { error: "the server responded with status 408 for http://blogs.nature.com/posts.json?doi=#{work.doi_escaped}", status: 408 }
      response = subject.parse_data(result, work_id: work.id)
      expect(response).to eq(result)
    end
  end
end
