require 'rails_helper'

describe Wikipedia, type: :model, vcr: true do
  before(:each) { allow(Time.zone).to receive(:now).and_return(Time.mktime(2015, 4, 8)) }

  subject { FactoryGirl.create(:wikipedia) }

  let(:work) { FactoryGirl.create(:work, :doi => "10.1371/journal.pone.0044294", canonical_url: "http://www.plosone.org/article/info:doi/10.1371/journal.pone.0044294") }

  context "query_url" do
    it "should return empty hash if the doi and canonical_url are missing" do
      work = FactoryGirl.create(:work, :doi => nil, canonical_url: nil)
      expect(subject.get_query_url(work_id: work.id)).to eq({})
    end

    it "should return a query without doi if the doi is missing" do
      work = FactoryGirl.create(:work, :doi => nil)
      expect(subject.get_query_url(work_id: work.id)).to eq("http://en.wikipedia.org/w/api.php?action=query&list=search&format=json&srsearch=#{subject.get_query_string(work_id: work.id)}&srnamespace=0&srwhat=text&srinfo=totalhits&srprop=timestamp&srlimit=50&sroffset=0&continue=")
    end
  end

  context "get_data" do
    it "should report that there are no events if the doi and url are missing" do
      work = FactoryGirl.create(:work, doi: nil, canonical_url: nil)
      expect(subject.get_data(work_id: work.id)).to eq("en"=>[])
    end

    it "should report if there are no events and event_count returned by the Wikipedia API" do
      response = subject.get_data(work_id: work.id)
      expect(response).to eq("en"=>[])
    end

    it "should report if there are events and event_count returned by the Wikipedia API" do
      work = FactoryGirl.create(:work, :doi => "10.1371/journal.pone.0008776", canonical_url: "http://journals.plos.org/plosone/article?id=10.1371/journal.pone.0008776")
      response = subject.get_data(work_id: work.id)
      expect(response["en"].length).to eq(627)
      expect(response["en"].first).to eq("title"=>"Bostrycapulus aculeatus", "url"=>"http://en.wikipedia.org/wiki/Bostrycapulus_aculeatus", "timestamp"=>"2015-03-21T07:47:45Z")
    end

    it "should catch timeout errors with the Wikipedia API" do
      work = FactoryGirl.create(:work, :doi => "10.1371/journal.pone.0000001")
      stub = stub_request(:get, /en.wikipedia.org/).to_return(:status => [408])
      response = subject.get_data(work_id: work, source_id: subject.source_id)
      expect(response).to eq("en"=>[])
      expect(stub).to have_been_requested
      expect(Notification.count).to eq(1)
      notification = Notification.first
      expect(notification.class_name).to eq("Net::HTTPRequestTimeOut")
      expect(notification.message).to eq("the server responded with status 408 for http://en.wikipedia.org/w/api.php?action=query&list=search&format=json&srsearch=#{subject.get_query_string(work_id: work.id)}&srnamespace=0&srwhat=text&srinfo=totalhits&srprop=timestamp&srlimit=50&sroffset=0&continue=")
      expect(notification.status).to eq(408)
    end
  end

  context "get_data from Wikimedia Commons" do
    subject { FactoryGirl.create(:wikipedia, languages: "en commons") }

    it "should report if there are events and event_count returned by the Wikimedia Commons API" do
      work = FactoryGirl.create(:work, doi: "10.1371/journal.pone.0044271", canonical_url: "http://www.plosone.org/article/info:doi/10.1371/journal.pone.0044271")
      response = subject.get_data(work_id: work.id)
      expect(response["en"].length).to eq(2)
      expect(response["commons"].length).to eq(8)
    end

  end

  context "parse_data" do
    it "should report if the doi and canonical_url are missing" do
      work = FactoryGirl.create(:work, doi: nil, canonical_url: nil)
      result = {}
      expect(subject.parse_data(result, work_id: work.id)).to eq([])
    end

    it "should report if there are no events and event_count returned by the Wikipedia API" do
      result = { "en"=>[] }
      expect(subject.parse_data(result, work_id: work.id)).to eq([])
    end

    it "should report if there are events and event_count returned by the Wikipedia API" do
      work = FactoryGirl.create(:work, :doi => "10.1371/journal.pone.0008776", canonical_url: "http://journals.plos.org/plosone/article?id=10.1371/journal.pone.0008776", published_on: "2007-07-01")
      body = File.read(fixture_path + 'wikipedia.json')
      result = JSON.parse(body)
      response = subject.parse_data(result, work_id: work.id)

      expect(response.length).to eq(637)
      expect(response.first[:relation]).to eq("subj_id"=>"http://en.wikipedia.org/wiki/Lobatus_costatus",
                                              "obj_id"=>work.pid,
                                              "relation_type_id"=>"references",
                                              "provenance_url"=>"http://en.wikipedia.org/w/index.php?search=%2210.1371/journal.pone.0008776%22+OR+%22http://journals.plos.org/plosone/article?id=10.1371%2Fjournal.pone.0008776%22",
                                              "source_id"=>"wikipedia")

      expect(response.first[:subj]).to eq("pid"=>"http://en.wikipedia.org/wiki/Lobatus_costatus",
                                          "author"=>nil,
                                          "title"=>"Lobatus costatus",
                                          "container-title"=>"Wikipedia",
                                          "issued"=>"2013-03-21T09:51:18Z",
                                          "URL"=>"http://en.wikipedia.org/wiki/Lobatus_costatus",
                                          "type"=>"entry-encyclopedia",
                                          "tracked"=>false,
                                          "registration_agency_id"=>"wikipedia")
    end

    it "should report if there are events and event_count returned by the Wikimedia Commons API" do
      work = FactoryGirl.create(:work, :doi => "10.1371/journal.pone.0044271", published_on: "2007-07-01")
      body = File.read(fixture_path + 'wikipedia_commons.json')
      result = JSON.parse(body)
      response = subject.parse_data(result, work_id: work.id)

      expect(response.length).to eq(10)
      expect(response.first[:relation]).to eq("subj_id"=>"http://en.wikipedia.org/wiki/Lesula",
                                              "obj_id"=>work.pid,
                                              "relation_type_id"=>"references",
                                              "provenance_url"=>"http://en.wikipedia.org/w/index.php?search=%22#{work.doi}%22+OR+%22#{work.canonical_url}%22",
                                              "source_id"=>"wikipedia")

      expect(response.first[:subj]).to eq("pid"=>"http://en.wikipedia.org/wiki/Lesula",
                                          "author"=>nil,
                                          "title"=>"Lesula",
                                          "container-title"=>"Wikipedia",
                                          "issued"=>"2014-05-24T12:54:07Z",
                                          "URL"=>"http://en.wikipedia.org/wiki/Lesula",
                                          "type"=>"entry-encyclopedia",
                                          "tracked"=>false,
                                          "registration_agency_id"=>"wikipedia")
    end

    it "should catch timeout errors with the Wikipedia API" do
      work = FactoryGirl.create(:work, :doi => "10.2307/683422")
      result = { error: "the server responded with status 408 for http://scienceseeker.org/search/default/?type=post&filter0=citation&modifier0=doi&value0=#{work.doi_escaped}", status: 408 }
      response = subject.parse_data(result, work_id: work.id)
      expect(response).to eq([result])
    end
  end
end
