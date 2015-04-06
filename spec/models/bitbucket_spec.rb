require 'rails_helper'

describe Bitbucket, type: :model, vcr: true do
  subject { FactoryGirl.create(:bitbucket) }

  let(:work) { FactoryGirl.create(:work, :canonical_url => "https://bitbucket.org/galaxy/galaxy-central") }

  context "get_data" do
    it "should report that there are no events if the canonical_url is missing" do
      work = FactoryGirl.build(:work, :canonical_url => nil)
      expect(subject.get_data(work)).to eq({})
    end

    it "should report that there are no events if the canonical_url is not a Bitbucket URL" do
      work = FactoryGirl.build(:work, :canonical_url => "https://code.google.com/p/gwtupload/")
      expect(subject.get_data(work)).to eq({})
    end

    it "should report if there are no events and event_count returned by the Bitbucket API" do
      body = File.read(fixture_path + 'bitbucket_nil.json')
      stub = stub_request(:get, subject.get_query_url(work)).to_return(:body => body)
      response = subject.get_data(work)
      expect(response).to eq(JSON.parse(body))
      expect(stub).to have_been_requested
    end

    it "should report if there are events and event_count returned by the Bitbucket API" do
      body = File.read(fixture_path + 'bitbucket.json')
      stub = stub_request(:get, subject.get_query_url(work)).to_return(:body => body)
      response = subject.get_data(work)
      expect(response).to eq(JSON.parse(body))
      expect(stub).to have_been_requested
    end

    it "should catch timeout errors with the bitbucket API" do
      stub = stub_request(:get, subject.get_query_url(work)).to_return(:status => [408])
      response = subject.get_data(work, options = { :source_id => subject.id })
      expect(response).to eq(error: "the server responded with status 408 for https://api.bitbucket.org/1.0/repositories/galaxy/galaxy-central", :status=>408)
      expect(stub).to have_been_requested
      expect(Alert.count).to eq(1)
      alert = Alert.first
      expect(alert.class_name).to eq("Net::HTTPRequestTimeOut")
      expect(alert.status).to eq(408)
      expect(alert.source_id).to eq(subject.id)
    end
  end

  context "parse_data" do
    it "should report if the canonical_url is missing" do
      work = FactoryGirl.build(:work, :canonical_url => nil)
      result = {}
      expect(subject.parse_data(result, work)).to eq(metrics: { source: "bitbucket", work: work.pid, readers: 0, likes: 0, total: 0, events_url: nil, extra: {} })
    end

    it "should report that there are no events if the canonical_url is not a Bitbucket URL" do
      work = FactoryGirl.build(:work, :canonical_url => "https://code.google.com/p/gwtupload/")
      result = {}
      expect(subject.parse_data(result, work)).to eq(metrics: { source: "bitbucket", work: work.pid, readers: 0, likes: 0, total: 0, events_url: nil, extra: {} })
    end

    it "should report if there are no events and event_count returned by the Bitbucket API" do
      body = File.read(fixture_path + 'bitbucket_nil.json')
      result = JSON.parse(body)
      extra = { "followers_count"=>0, "forks_count"=>0, "description"=>"Exemplos da Aula 1 do curso de Desenvolvimento Web com Ruby on Rails do ruby+web\r\n\r\nhttp://rubymaisweb.ning.com", "utc_created_on"=>"2012-01-13 14:47:01+00:00" }
      response = subject.parse_data(result, work)
      expect(response).to eq(metrics: { source: "bitbucket", work: work.pid, readers: 0, likes: 0, total: 0, events_url: nil, extra: extra })
    end

    it "should report if there are events and event_count returned by the Bitbucket API" do
      body = File.read(fixture_path + 'bitbucket.json')
      result = JSON.parse(body)
      response = subject.parse_data(result, work)
      expect(response[:metrics][:total]).to eq(434)
      expect(response[:metrics][:readers]).to eq(272)
      expect(response[:metrics][:likes]).to eq(162)
      expect(response[:metrics][:events_url]).to eq("https://bitbucket.org/galaxy/galaxy-central")
      expect(response[:metrics][:extra]["followers_count"]).to eq(162)
    end

    it "should catch timeout errors with the Bitbucket API" do
      work = FactoryGirl.create(:work, :doi => "10.1371/journal.pone.0000001")
      result = { error: "the server responded with status 408 for https://api.bitbucket.org/1.0/repositories/galaxy/galaxy-central", status: 408 }
      response = subject.parse_data(result, work)
      expect(response).to eq(result)
    end
  end
end
