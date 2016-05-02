require 'rails_helper'

describe Github, type: :model, vcr: true do
  subject { FactoryGirl.create(:github) }

  let(:work) { FactoryGirl.create(:work, pid: "https://github.com/ropensci/alm", canonical_url: "https://github.com/ropensci/alm") }

  context "get_data" do
    it "should report that there are no events if the canonical_url is missing" do
      work = FactoryGirl.create(:work, :canonical_url => nil)
      expect(subject.get_data(work_id: work.id)).to eq({})
    end

    it "should report that there are no events if the canonical_url is not a Github URL" do
      work = FactoryGirl.create(:work, :canonical_url => "https://code.google.com/p/gwtupload/")
      expect(subject.get_data(work_id: work.id)).to eq({})
    end

    it "should report if there are no events and event_count returned by the Github API" do
      body = File.read(fixture_path + 'github_nil.json')
      query_url = subject.get_query_url(subject.get_owner_and_repo(work))
      stub = stub_request(:get, query_url).to_return(:body => body)
      response = subject.get_data(work_id: work.id)
      expect(response).to eq(JSON.parse(body))
      expect(stub).to have_been_requested
    end

    it "should report if there are events and event_count returned by the Github API" do
      body = File.read(fixture_path + 'github.json')
      query_url = subject.get_query_url(subject.get_owner_and_repo(work))
      stub = stub_request(:get, query_url).to_return(:body => body)
      response = subject.get_data(work_id: work.id)
      expect(response).to eq(JSON.parse(body))
      expect(stub).to have_been_requested
    end

    it "should catch timeout errors with the github API" do
      query_url = subject.get_query_url(subject.get_owner_and_repo(work))
      stub = stub_request(:get, query_url).to_return(:status => [408])
      response = subject.get_data(work_id: work.id, source_id: subject.source_id)
      expect(response).to eq(error: "the server responded with status 408 for https://api.github.com/repos/ropensci/alm", :status=>408)
      expect(stub).to have_been_requested
      expect(Notification.count).to eq(1)
      notification = Notification.first
      expect(notification.class_name).to eq("Net::HTTPRequestTimeOut")
      expect(notification.status).to eq(408)
    end
  end

  context "parse_data" do
    let(:extra) { { "stargazers_count"=>0, "stargazers_url"=>"https://api.github.com/repos/articlemetrics/pyalm/stargazers", "forks_count"=>0, "forks_url"=>"https://api.github.com/repos/articlemetrics/pyalm/forks" } }
    it "should report if the canonical_url is missing" do
      work = FactoryGirl.create(:work, :canonical_url => nil)
      result = {}
      expect(subject.parse_data(result, work_id: work.id)).to eq([])
    end

    it "should report that there are no events if the canonical_url is not a Github URL" do
      work = FactoryGirl.create(:work, :canonical_url => "https://code.google.com/p/gwtupload/")
      result = {}
      expect(subject.parse_data(result, work_id: work.id)).to eq([])
    end

    it "should report if there are no events returned by the Github API" do
      body = File.read(fixture_path + 'github_nil.json')
      result = JSON.parse(body)
      extra = { "stargazers_count"=>0, "stargazers_url"=>"https://api.github.com/repos/articlemetrics/pyalm/stargazers", "forks_count"=>0, "forks_url"=>"https://api.github.com/repos/articlemetrics/pyalm/forks" }
      response = subject.parse_data(result, work_id: work.id)
      expect(response).to eq([])
    end

    it "should report if there are events returned by the Github API" do
      allow(Time.zone).to receive(:now).and_return(Time.mktime(2013, 9, 5))
      body = File.read(fixture_path + 'github.json')
      result = JSON.parse(body)
      response = subject.parse_data(result, work_id: work.id)

      expect(response.length).to eq(2)
      expect(response.first[:occurred_at]).to eq("2013-09-01")
      expect(response.first[:relation]).to eq("subj_id"=>"https://github.com/2013/9",
                                              "obj_id"=>"https://github.com/ropensci/alm",
                                              "relation_type_id"=>"bookmarks",
                                              "total"=>7,
                                              "provenance_url" => "https://github.com/ropensci/alm",
                                              "source_id"=>"github",
                                              "registration_agency_id" => "github")
      expect(response.first[:subj]).to eq("pid"=>"https://github.com/2013/9",
                                          "URL"=>"https://github.com", "title"=>"Github activity for September 2013",
                                          "type"=>"webpage",
                                          "issued"=>"2013-09-01")

      expect(response.first[:occurred_at]).to eq("2013-09-01")
      expect(response.last[:relation]).to eq("subj_id"=>"https://github.com/2013/9",
                                             "obj_id"=>"https://github.com/ropensci/alm",
                                             "relation_type_id"=>"is_derived_from",
                                             "total"=>3,
                                             "provenance_url" => "https://github.com/ropensci/alm",
                                             "source_id"=>"github",
                                             "registration_agency_id" => "github")
    end

    it "should catch timeout errors with the github API" do
      work = FactoryGirl.create(:work, :doi => "10.1371/journal.pone.0000001")
      result = { error: "the server responded with status 408 for https://api.github.com/repos/ropensci/alm", status: 408 }
      response = subject.parse_data(result, work_id: work.id)
      expect(response).to eq([result])
    end
  end
end
