require 'rails_helper'

describe Researchblogging, type: :model, vcr: true do
  subject { FactoryGirl.create(:researchblogging) }

  context "get_data" do
    let(:auth) { ActionController::HttpAuthentication::Basic.encode_credentials(subject.username, subject.password) }

    it "should report that there are no events if the doi is missing" do
      work = FactoryGirl.create(:work, :doi => "")
      expect(subject.get_data(work)).to eq({})
    end

    it "should report if there are no events returned by the ResearchBlogging API" do
      work = FactoryGirl.create(:work, :doi => "10.1371/journal.pmed.0020124")
      body = File.read(fixture_path + 'researchblogging_nil.xml')
      stub = stub_request(:get, "http://researchbloggingconnect.com/blogposts?article=doi:#{work.doi_escaped}&count=100").with(:headers => { :authorization => auth }).to_return(:body => body)
      response = subject.get_data(work)
      expect(response).to eq(Hash.from_xml(body))
      expect(stub).to have_been_requested
    end

    it "should report if there are events returned by the ResearchBlogging API" do
      work = FactoryGirl.create(:work, :doi => "10.1371/journal.pone.0035869")
      body = File.read(fixture_path + 'researchblogging.xml')
      stub = stub_request(:get, "http://researchbloggingconnect.com/blogposts?article=doi:#{work.doi_escaped}&count=100").with(:headers => { :authorization => auth }).to_return(:body => body)
      response = subject.get_data(work)
      expect(response).to eq(Hash.from_xml(body))
      expect(stub).to have_been_requested
    end

    it "should catch errors with the ResearchBlogging API" do
      work = FactoryGirl.create(:work, :doi => "10.1371/journal.pone.0000001")
      stub = stub_request(:get, "http://researchbloggingconnect.com/blogposts?article=doi:#{work.doi_escaped}&count=100").with(:headers => { :authorization => auth }).to_return(:status => [408])
      response = subject.get_data(work, options = { :source_id => subject.id })
      expect(response).to eq(error: "the server responded with status 408 for http://researchbloggingconnect.com/blogposts?count=100&article=doi:#{work.doi_escaped}", :status=>408)
      expect(stub).to have_been_requested
      expect(Alert.count).to eq(1)
      alert = Alert.first
      expect(alert.class_name).to eq("Net::HTTPRequestTimeOut")
      expect(alert.status).to eq(408)
      expect(alert.source_id).to eq(subject.id)
    end
  end

  context "parse_data" do
    let(:work) { FactoryGirl.create(:work, :doi => "10.1371/journal.pmed.0020124") }

    it "should report if the doi is missing" do
      work = FactoryGirl.create(:work, :doi => "")
      result = {}
      result.extend Hashie::Extensions::DeepFetch
      expect(subject.parse_data(result, work)).to eq(works: [], metrics: { source: "researchblogging", work: work.pid, total: 0, days: [], months: [] })
    end

    it "should report if there are no events returned by the ResearchBlogging API" do
      body = File.read(fixture_path + 'researchblogging_nil.xml')
      result = Hash.from_xml(body)
      result.extend Hashie::Extensions::DeepFetch
      response = subject.parse_data(result, work)
      expect(response).to eq(works: [], metrics: { source: "researchblogging", work: work.pid, total: 0, days: [], months: [] })
    end

    it "should report if there are events returned by the ResearchBlogging API" do
      work = FactoryGirl.create(:work, :doi => "10.1371/journal.pone.0035869", published_on: "2009-07-01")
      body = File.read(fixture_path + 'researchblogging.xml')
      result = Hash.from_xml(body)
      result.extend Hashie::Extensions::DeepFetch
      response = subject.parse_data(result, work)
      expect(response[:works].length).to eq(8)
      expect(response[:metrics][:total]).to eq(8)
      expect(response[:metrics][:events_url]).to eq(subject.get_events_url(work))
      expect(response[:metrics][:days].length).to eq(7)
      expect(response[:metrics][:days].first).to eq(year: 2009, month: 7, day: 6, total: 1)
      expect(response[:metrics][:months].length).to eq(7)
      expect(response[:metrics][:months].first).to eq(year: 2009, month: 7, total: 1)

      event = response[:works].first
      expect(event['URL']).to eq("http://laikaspoetnik.wordpress.com/2012/10/27/why-publishing-in-the-nejm-is-not-the-best-guarantee-that-something-is-true-a-response-to-katan/")
      expect(event['author']).to eq([{"family"=>"Spoetnik", "given"=>"Laika"}])
      expect(event['title']).to eq("Why Publishing in the NEJM is not the Best Guarantee that Something is True: a Response to Katan")
      expect(event['container-title']).to eq("Laika's Medliblog")
      expect(event['issued']).to eq("date-parts"=>[[2012, 10, 27]])
      expect(event['type']).to eq("post")
    end

    it "should report if there is one event returned by the ResearchBlogging API" do
      work = FactoryGirl.create(:work, :doi => "10.1371/journal.pone.0035869", published_on: "2012-10-01")
      body = File.read(fixture_path + 'researchblogging_one.xml')
      result = Hash.from_xml(body)
      result.extend Hashie::Extensions::DeepFetch
      response = subject.parse_data(result, work)
      expect(response[:works].length).to eq(1)
      expect(response[:metrics][:total]).to eq(1)
      expect(response[:metrics][:events_url]).to eq(subject.get_events_url(work))
      expect(response[:metrics][:days].length).to eq(1)
      expect(response[:metrics][:days].first).to eq(year: 2012, month: 10, day: 27, total: 1)
      expect(response[:metrics][:months].length).to eq(1)
      expect(response[:metrics][:months].first).to eq(year: 2012, month: 10, total: 1)

      event = response[:works].first
      expect(event['URL']).to eq("http://laikaspoetnik.wordpress.com/2012/10/27/why-publishing-in-the-nejm-is-not-the-best-guarantee-that-something-is-true-a-response-to-katan/")
      expect(event['author']).to eq([{"family"=>"Spoetnik", "given"=>"Laika"}])
      expect(event['title']).to eq("Why Publishing in the NEJM is not the Best Guarantee that Something is True: a Response to Katan")
      expect(event['container-title']).to eq("Laika's Medliblog")
      expect(event['issued']).to eq("date-parts"=>[[2012, 10, 27]])
      expect(event['type']).to eq("post")
    end

    it "should catch timeout errors with the ResearchBlogging API" do
      result = { error: "the server responded with status 408 for http://researchbloggingconnect.com/blogposts?count=100&work=doi:#{work.doi_escaped}", status: 408 }
      response = subject.parse_data(result, work)
      expect(response).to eq(result)
    end
  end
end
