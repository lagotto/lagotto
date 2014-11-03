require 'rails_helper'

describe ArticleCoverageCurated, :type => :model do
  subject { FactoryGirl.create(:article_coverage_curated) }

  let(:article) { FactoryGirl.build(:article, :doi => "10.1371/journal.pone.0047712", published_on: "2013-11-01") }

  it "should report that there are no events if the doi is missing" do
    article = FactoryGirl.build(:article, :doi => nil)
    expect(subject.get_data(article)).to eq({})
  end

  it "should report that there are no events if the doi has the wrong prefix" do
    article = FactoryGirl.build(:article, :doi => "10.5194/acp-12-12021-2012")
    expect(subject.get_data(article)).to eq({})
  end

  context "get_data from the Article Coverage API" do
    it "should report if article doesn't exist in Article Coverage source" do
      article = FactoryGirl.build(:article, :doi => "10.1371/journal.pone.0008776")
      stub = stub_request(:get, subject.get_query_url(article)).to_return(:body => {"error" => "Article not found"}.to_json, :status => 404)
      expect(subject.get_data(article)).to eq(error: "Article not found", status: 404)
      expect(stub).to have_been_requested
    end

    it "should report if there are no events and event_count returned by the Article Coverage API" do
      article = FactoryGirl.build(:article, :doi => "10.1371/journal.pone.0008775")
      body = File.read(fixture_path + 'article_coverage_curated_nil.json')
      stub = stub_request(:get, subject.get_query_url(article)).to_return(:body => body)
      response = subject.get_data(article)
      expect(response).to eq(JSON.parse(body))
      expect(stub).to have_been_requested
    end

    it "should report if there are events and event_count returned by the Article Coverage API" do
      body = File.read(fixture_path + 'article_coverage_curated.json')
      stub = stub_request(:get, subject.get_query_url(article)).to_return(:body => body)
      response = subject.get_data(article)
      expect(response).to eq(JSON.parse(body))
      expect(stub).to have_been_requested
    end

    it "should catch timeout errors with the Article Coverage API" do
      stub = stub_request(:get, subject.get_query_url(article)).to_return(:status => [408])
      response = subject.get_data(article, options = { :source_id => subject.id })
      expect(response).to eq(error: "the server responded with status 408 for http://example.org?doi=#{article.doi_escaped}", :status=>408, :status=>408)
      expect(stub).to have_been_requested
      expect(Alert.count).to eq(1)
      alert = Alert.first
      expect(alert.class_name).to eq("Net::HTTPRequestTimeOut")
      expect(alert.status).to eq(408)
      expect(alert.source_id).to eq(subject.id)
    end
  end

  context "parse_data from the Article Coverage API" do
    it "should report if the doi is missing" do
      article = FactoryGirl.build(:article, :doi => nil)
      result = {}
      expect(subject.parse_data(result, article)).to eq(:events=>[], :events_by_day=>[], :events_by_month=>[], :events_url=>nil, :event_count=>0, :event_metrics=>{:pdf=>nil, :html=>nil, :shares=>nil, :groups=>nil, :comments=>0, :likes=>nil, :citations=>nil, :total=>0})
    end

    it "should report if article doesn't exist in Article Coverage source" do
      result = { error: "Article not found", status: 404 }
      response = subject.parse_data(result, article)
      expect(response).to eq(:events=>[], :events_by_day=>[], :events_by_month=>[], :events_url=>nil, :event_count=>0, :event_metrics=>{:pdf=>nil, :html=>nil, :shares=>nil, :groups=>nil, :comments=>0, :likes=>nil, :citations=>nil, :total=>0})
    end

    it "should report if there are no events and event_count returned by the Article Coverage API" do
      body = File.read(fixture_path + 'article_coverage_curated_nil.json')
      result = JSON.parse(body)
      response = subject.parse_data(result, article)
      expect(response).to eq(:events=>[], :events_by_day=>[], :events_by_month=>[], :events_url=>nil, :event_count=>0, :event_metrics=>{:pdf=>nil, :html=>nil, :shares=>nil, :groups=>nil, :comments=>0, :likes=>nil, :citations=>nil, :total=>0})
    end

    it "should report if there are events and event_count returned by the Article Coverage API" do
      body = File.read(fixture_path + 'article_coverage_curated.json')
      result = JSON.parse(body)
      response = subject.parse_data(result, article)
      expect(response[:events].length).to eq(15)

      expect(response[:events_by_day].length).to eq(1)
      expect(response[:events_by_day].first).to eq(year: 2013, month: 11, day: 20, total: 2)
      expect(response[:events_by_month].length).to eq(1)
      expect(response[:events_by_month].first).to eq(year: 2013, month: 11, total: 2)

      expect(response[:event_count]).to eq(15)
      event = response[:events].first

      expect(event[:event_csl]['author']).to eq("")
      expect(event[:event_csl]['title']).to eq("Project Description @ Belly Button Biodiversity")
      expect(event[:event_csl]['container-title']).to eq("")
      expect(event[:event_csl]['issued']).to be_nil
      expect(event[:event_csl]['type']).to eq("post")

      event_data = event[:event]
      expect(event_data['referral']).to eq("http://www.wildlifeofyourbody.org/?page_id=1348")
      expect(event_data['language']).to eq("English")
      expect(event_data['title']).to eq("Project Description @ Belly Button Biodiversity")
      expect(event_data['type']).to eq("Blog")
      expect(event_data['publication']).to eq("")
      expect(event_data['published_on']).to eq("")
      expect(event_data['link_state']).to eq("")

      expect(event[:event_time]).to be_nil
      expect(event[:event_url]).to eq("http://www.wildlifeofyourbody.org/?page_id=1348")
    end

    it "should catch timeout errors with the Article Coverage API" do
      result = { error: "the server responded with status 408 for http://example.org?doi=#{article.doi_escaped}", status: 408 }
      response = subject.parse_data(result, article)
      expect(response).to eq(result)
    end
  end
end
