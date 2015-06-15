require 'rails_helper'

describe Citeulike, type: :model, vcr: true do
  subject { FactoryGirl.create(:citeulike) }

  let(:work) { FactoryGirl.create(:work, :doi => "10.1371/journal.pone.0115074", published_on: "2006-06-01") }

  context "get_data" do
    it "should report that there are no events if the doi is missing" do
      work = FactoryGirl.create(:work, :doi => nil)
      expect(subject.get_data(work)).to eq({})
    end

    it "should report if there are no events returned by the CiteULike API" do
      work = FactoryGirl.create(:work, :doi => "10.1371/journal.pone.0116034")
      response = subject.get_data(work)
      expect(response).to eq("posts"=>nil)
    end

    it "should report if there is an incomplete response returned by the CiteULike API" do
      body = File.read(fixture_path + 'citeulike_incomplete.xml')
      stub = stub_request(:get, subject.get_query_url(work)).to_return(:body => body)
      response = subject.get_data(work)
      expect(response).to eq('data' => body)
      expect(stub).to have_been_requested
    end

    it "should report if there are events returned by the CiteULike API" do
      response = subject.get_data(work)
      expect(response["posts"]["post"].length).to eq(4)
      post = response["posts"]["post"].first
      expect(post["linkout"]["url"]).to eq("http://dx.doi.org/10.1371/journal.pone.0115074")
    end

    it "should catch errors with the CiteULike API" do
      stub = stub_request(:get, subject.get_query_url(work)).to_return(:status => [408])
      response = subject.get_data(work, source_id: subject.id)
      expect(response).to eq(error: "the server responded with status 408 for http://www.citeulike.org/api/posts/for/doi/#{work.doi_escaped}", :status=>408)
      expect(stub).to have_been_requested
      expect(Alert.count).to eq(1)
      alert = Alert.first
      expect(alert.class_name).to eq("Net::HTTPRequestTimeOut")
      expect(alert.status).to eq(408)
      expect(alert.source_id).to eq(subject.id)
    end
  end

  context "parse_data" do
    let(:null_response) { { works: [], events: { source: "citeulike", work: work.pid, readers: 0, total: 0, extra: [], days: [], months: [] } } }

    it "should report if the doi is missing" do
      work = FactoryGirl.create(:work, :doi => nil)
      result = { error: "query_url is nil." }
      expect(subject.parse_data(result, work)).to eq(error: "query_url is nil.")
    end

    it "should report if there are no events returned by the CiteULike API" do
      body = File.read(fixture_path + 'citeulike_nil.xml')
      result = Hash.from_xml(body)
      expect(subject.parse_data(result, work)).to eq(null_response)
    end

    it "should report if there is an incomplete response returned by the CiteULike API" do
      body = File.read(fixture_path + 'citeulike_incomplete.xml')
      result = { 'data' => body }
      expect(subject.parse_data(result, work)).to eq(null_response)
    end

    it "should report if there are events returned by the CiteULike API" do
      body = File.read(fixture_path + 'citeulike.xml')
      result = Hash.from_xml(body)

      response = subject.parse_data(result, work)
      expect(response[:works].length).to eq(25)
      expect(response[:events][:total]).to eq(25)
      expect(response[:events][:readers]).to eq(25)
      expect(response[:events][:events_url]).to eq(subject.get_events_url(work))
      expect(response[:events][:months].length).to eq(21)
      expect(response[:events][:months].first).to eq(year: 2006, month: 6, total: 2, readers: 2)

      event = response[:works].first
      expect(event['URL']).to eq("http://www.citeulike.org/user/dbogartoit")
      expect(event['author']).to eq([{"family"=>"Dbogartoit", "given"=>""}])
      expect(event['title']).to eq("CiteULike bookmarks for user dbogartoit")
      expect(event['container-title']).to eq("CiteULike")
      expect(event['issued']).to eq("date-parts"=>[[2006, 6, 13]])
      expect(event['type']).to eq("entry")
      expect(event["timestamp"]).to eq("2006-06-13T16:14:19Z")
      expect(event["related_works"]).to eq([{"related_work"=> work.pid, "source"=>"citeulike", "relation_type"=>"bookmarks"}])

      extra = response[:events][:extra].first
      expect(extra[:event_time]).to eq("2006-06-13T16:14:19Z")
      expect(extra[:event_url]).to eq(extra[:event]['link']['url'])
    end

    it "should report if there is one event returned by the CiteULike API" do
      body = File.read(fixture_path + 'citeulike_one.xml')
      result = Hash.from_xml(body)

      response = subject.parse_data(result, work)
      expect(response[:works].length).to eq(1)
      expect(response[:events][:total]).to eq(1)
      expect(response[:events][:readers]).to eq(1)
      expect(response[:events][:events_url]).to eq(subject.get_events_url(work))
      expect(response[:events][:months].length).to eq(1)
      expect(response[:events][:months].first).to eq(year: 2006, month: 6, total: 1, readers: 1)

      event = response[:works].first
      expect(event['URL']).to eq("http://www.citeulike.org/user/dbogartoit")
      expect(event['author']).to eq([{"family"=>"Dbogartoit", "given"=>""}])
      expect(event['title']).to eq("CiteULike bookmarks for user dbogartoit")
      expect(event['container-title']).to eq("CiteULike")
      expect(event['issued']).to eq("date-parts"=>[[2006, 6, 13]])
      expect(event['type']).to eq("entry")
      expect(event["timestamp"]).to eq("2006-06-13T16:14:19Z")
      expect(event["related_works"]).to eq([{"related_work"=> work.pid, "source"=>"citeulike", "relation_type"=>"bookmarks"}])
    end

    it "should catch timeout errors with the CiteULike API" do
      result = { error: "the server responded with status 408 for http://www.citeulike.org/api/posts/for/doi/#{work.doi_escaped}", status: 408 }
      response = subject.parse_data(result, work)
      expect(response).to eq(result)
    end
  end
end
