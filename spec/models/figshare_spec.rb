require 'rails_helper'

describe Figshare, :type => :model do
  subject { FactoryGirl.create(:figshare) }

  let(:article) { FactoryGirl.create(:article, :doi => "10.1371/journal.pone.0067729") }

  context "get_data" do
    it "should report that there are no events if the doi is missing" do
      article = FactoryGirl.build(:article, :doi => nil)
      expect(subject.get_data(article)).to eq({})
    end

    it "should report that there are no events if the doi has the wrong prefix" do
      article = FactoryGirl.build(:article, :doi => "10.5194/acp-12-12021-2012")
      expect(subject.get_data(article)).to eq({})
    end

    it "should report if there are no events and event_count returned by the figshare API" do
      body = File.read(fixture_path + 'figshare_nil.json')
      stub = stub_request(:get, subject.get_query_url(article)).to_return(:body => body)
      response = subject.get_data(article)
      expect(response).to eq(JSON.parse(body))
      expect(stub).to have_been_requested
    end

    it "should report if there are events and event_count returned by the figshare API" do
      body = File.read(fixture_path + 'figshare.json')
      stub = stub_request(:get, subject.get_query_url(article)).to_return(:body => body)
      response = subject.get_data(article)
      expect(response).to eq(JSON.parse(body))
      expect(stub).to have_been_requested
    end

    it "should catch timeout errors with the figshare API" do
      stub = stub_request(:get, subject.get_query_url(article)).to_return(:status => [408])
      response = subject.get_data(article, options = { :source_id => subject.id })
      expect(response).to eq(error: "the server responded with status 408 for http://api.figshare.com/v1/publishers/search_for?doi=#{article.doi}", :status=>408)
      expect(stub).to have_been_requested
      expect(Alert.count).to eq(1)
      alert = Alert.first
      expect(alert.class_name).to eq("Net::HTTPRequestTimeOut")
      expect(alert.status).to eq(408)
      expect(alert.source_id).to eq(subject.id)
    end
  end

  context "parse_data" do
    let(:null_response) { { :events=>[], :events_by_day=>[], :events_by_month=>[], :events_url=>nil, :event_count=>0, :event_metrics=>{:pdf=>0, :html=>0, :shares=>nil, :groups=>nil, :comments=>nil, :likes=>0, :citations=>nil, :total=>0} } }

    it "should report if the doi is missing" do
      article = FactoryGirl.build(:article, :doi => nil)
      result = {}
      expect(subject.parse_data(result, article)).to eq(null_response)
    end

    it "should report that there are no events if the doi has the wrong prefix" do
      article = FactoryGirl.build(:article, :doi => "10.5194/acp-12-12021-2012")
      result = {}
      expect(subject.parse_data(result, article)).to eq(null_response)
    end

    it "should report if there are no events and event_count returned by the figshare API" do
      body = File.read(fixture_path + 'figshare_nil.json')
      result = JSON.parse(body)
      response = subject.parse_data(result, article)
      expect(response).to eq(null_response)
    end

    it "should report if there are events and event_count returned by the figshare API" do
      body = File.read(fixture_path + 'figshare.json')
      result = JSON.parse(body)
      response = subject.parse_data(result, article)
      expect(response[:event_count]).to eq(14)
      expect(response[:events].length).to eq(6)
      expect(response[:event_metrics]).to eq(pdf: 1, html: 13, shares: nil, groups: nil, comments: nil, likes: 0, citations: nil, total: 14)
    end

    it "should catch timeout errors with the figshare API" do
      article = FactoryGirl.create(:article, :doi => "10.1371/journal.pone.0000001")
      result = { error: "the server responded with status 408 for http://api.figshare.com/v1/publishers/search_for?doi=#{article.doi}", status: 408 }
      response = subject.parse_data(result, article)
      expect(response).to eq(result)
    end
  end
end
