require 'rails_helper'

describe CrossrefPublisher, type: :model, vcr: true do
  before(:each) { allow(Time.zone).to receive(:now).and_return(Time.mktime(2015, 4, 8)) }

  subject { FactoryGirl.create(:crossref_publisher) }

  context "config_fields" do
    it "url_fields" do
      expect(subject.url_fields).to eq([:url])
    end

    it "other_fields" do
      expect(subject.other_fields).to be_empty
    end
  end

  context "get_query_url" do
    it "default" do
      expect(subject.get_query_url).to eq("http://api.crossref.org/members?offset=0&rows=1000")
    end

    it "with zero rows" do
      expect(subject.get_query_url(rows: 0)).to eq("http://api.crossref.org/members?offset=0&rows=0")
    end

    it "with offset" do
      expect(subject.get_query_url(offset: 250)).to eq("http://api.crossref.org/members?offset=250&rows=1000")
    end

    it "with rows" do
      expect(subject.get_query_url(rows: 250)).to eq("http://api.crossref.org/members?offset=0&rows=250")
    end
  end

  context "get_total" do
    it "with members" do
      expect(subject.get_total).to eq(6260)
    end
  end

  context "queue_jobs" do
    it "should report if there are members returned by the Crossref REST API" do
      response = subject.queue_jobs
      expect(response).to eq(6260)
    end
  end

  context "get_data" do
    it "should report if there are members returned by the Crossref REST API" do
      response = subject.get_data
      expect(response["message"]["total-results"]).to eq(6260)
      item = response["message"]["items"].first
      expect(item['primary-name']).to eq("Hogrefe Publishing Group")
      expect(item['prefixes']).to eq(["10.1024", "10.1026", "10.1027"])
    end

    it "should catch errors with the Crossref REST API" do
      stub = stub_request(:get, subject.get_query_url(rows: 0, source_id: subject.source_id)).to_return(:status => [408])
      response = subject.get_data(rows: 0, source_id: subject.source_id)
      expect(response).to eq(error: "the server responded with status 408 for http://api.crossref.org/members?offset=0&rows=0", :status=>408)
      expect(stub).to have_been_requested
      expect(Notification.count).to eq(1)
      notification = Notification.first
      expect(notification.class_name).to eq("Net::HTTPRequestTimeOut")
      expect(notification.status).to eq(408)
    end
  end

  context "parse_data" do
    it "should report if there are no members returned by the Crossref REST API" do
      body = File.read(fixture_path + 'crossref_publisher_nil.json')
      result = JSON.parse(body)
      expect(subject.parse_data(result)).to eq([])
    end

    it "should report if there are members returned by the Crossref REST API" do
      body = File.read(fixture_path + 'crossref_publisher.json')
      result = JSON.parse(body)
      response = subject.parse_data(result)

      expect(response.length).to eq(20)
      expect(response.first[:message_type]).to eq("publisher")
      expect(response.first[:relation]).to eq("subj_id"=>"101", "source_id"=>"crossref_publisher")
      expect(response.first[:subj]).to eq("name"=>"101",
                                          "title"=>"Hogrefe & Huber",
                                          "other_names"=>["Hogrefe & Huber Publishing Group", "Hogrefe & Huber"],
                                          "prefixes"=>["10.1024", "10.1026", "10.1027"],
                                          "issued" => "2015-10-26T05:00:49Z",
                                          "registration_agency_id"=>"crossref",
                                          "active"=>true)
    end
  end
end
