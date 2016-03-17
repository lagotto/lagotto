require 'rails_helper'

describe Citeulike, type: :model, vcr: true do
  subject { FactoryGirl.create(:citeulike) }

  let(:work) { FactoryGirl.create(:work, :doi => "10.1371/journal.pone.0115074", published_on: "2006-06-01") }

  context "get_data" do
    it "should report that there are no events if the doi is missing" do
      work = FactoryGirl.create(:work, :doi => nil)
      expect(subject.get_data(work_id: work.id)).to eq({})
    end

    it "should report if there are no events returned by the CiteULike API" do
      work = FactoryGirl.create(:work, :doi => "10.1371/journal.pone.0116034")
      response = subject.get_data(work_id: work.id)
      expect(response).to eq("posts"=>nil)
    end

    it "should report if there is an incomplete response returned by the CiteULike API" do
      body = File.read(fixture_path + 'citeulike_incomplete.xml')
      stub = stub_request(:get, subject.get_query_url(work_id: work.id)).to_return(:body => body)
      response = subject.get_data(work_id: work.id)
      expect(response).to eq('data' => body)
      expect(stub).to have_been_requested
    end

    it "should report if there are events returned by the CiteULike API" do
      response = subject.get_data(work_id: work.id)
      expect(response["posts"]["post"].length).to eq(6)
      post = response["posts"]["post"].first
      expect(post["linkout"][0]["url"]).to eq("http://dx.doi.org/10.1371/journal.pone.0115074")
    end

    it "should catch errors with the CiteULike API" do
      stub = stub_request(:get, subject.get_query_url(work_id: work.id)).to_return(:status => [408])
      response = subject.get_data(work_id: work.id, agent_id: subject.id)
      expect(response).to eq(error: "the server responded with status 408 for http://www.citeulike.org/api/posts/for/doi/#{work.doi_escaped}", :status=>408)
      expect(stub).to have_been_requested
      expect(Notification.count).to eq(1)
      notification = Notification.first
      expect(notification.class_name).to eq("Net::HTTPRequestTimeOut")
      expect(notification.status).to eq(408)
      expect(notification.agent_id).to eq(subject.id)
    end
  end

  context "parse_data" do
    # TODO include triples?

    it "should report if the doi is missing" do
      work = FactoryGirl.create(:work, :doi => nil)
      result = { error: "query_url is nil." }
      expect(subject.parse_data(result, work_id: work.id)).to eq([{ error: "query_url is nil." }])
    end

    it "should report if there are no events returned by the CiteULike API" do
      body = File.read(fixture_path + 'citeulike_nil.xml')
      result = Hash.from_xml(body)
      expect(subject.parse_data(result, work_id: work.id)).to eq([])
    end

    it "should report if there is an incomplete response returned by the CiteULike API" do
      body = File.read(fixture_path + 'citeulike_incomplete.xml')
      result = { 'data' => body }
      expect(subject.parse_data(result, work_id: work.id)).to eq([])
    end

    it "should report if there are events returned by the CiteULike API" do
      body = File.read(fixture_path + 'citeulike.xml')
      result = Hash.from_xml(body)
      response = subject.parse_data(result, work_id: work.id)

      expect(response.length).to eq(25)
      expect(response.first[:relation]).to eq("subj_id" => "http://www.citeulike.org/user/dbogartoit",
                                              "obj_id" => work.pid,
                                              "relation_type_id" => "bookmarks",
                                              "source_id" => "citeulike",
                                              "occurred_at" => "2006-06-13T16:14:19Z",
                                              "provenance_url" => "http://www.citeulike.org/doi/10.1371%2Fjournal.pone.0115074")

      expect(response.first[:subj]).to eq("pid"=>"http://www.citeulike.org/user/dbogartoit",
                                          "author"=>[{"given"=>"dbogartoit"}],
                                          "title"=>"CiteULike bookmarks for user dbogartoit",
                                          "container-title"=>"CiteULike",
                                          "issued"=>"2006-06-13T16:14:19Z",
                                          "URL"=>"http://www.citeulike.org/api/posts/for/doi/%{doi}",
                                          "type"=>"entry",
                                          "tracked"=>false)
    end

    it "should report if there is one event returned by the CiteULike API" do
      body = File.read(fixture_path + 'citeulike_one.xml')
      result = Hash.from_xml(body)
      response = subject.parse_data(result, work_id: work.id)

      expect(response.length).to eq(1)
      expect(response.first[:relation]).to eq("subj_id" => "http://www.citeulike.org/user/dbogartoit",
                                              "obj_id" => work.pid,
                                              "relation_type_id" => "bookmarks",
                                              "source_id" => "citeulike",
                                              "occurred_at" => "2006-06-13T16:14:19Z",
                                              "provenance_url" => "http://www.citeulike.org/doi/10.1371%2Fjournal.pone.0115074")

      expect(response.first[:subj]).to eq("pid"=>"http://www.citeulike.org/user/dbogartoit",
                                          "author"=>[{"given"=>"dbogartoit"}],
                                          "title"=>"CiteULike bookmarks for user dbogartoit",
                                          "container-title"=>"CiteULike",
                                          "issued"=>"2006-06-13T16:14:19Z",
                                          "URL"=>"http://www.citeulike.org/api/posts/for/doi/%{doi}",
                                          "type"=>"entry",
                                          "tracked"=>false)
    end

    it "should catch timeout errors with the CiteULike API" do
      result = [{ error: "the server responded with status 408 for http://www.citeulike.org/api/posts/for/doi/#{work.doi_escaped}", status: 408 }]
      response = subject.parse_data(result, work_id: work.id)
      expect(response).to eq(result)
    end
  end
end
