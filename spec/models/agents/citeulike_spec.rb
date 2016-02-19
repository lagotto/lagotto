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
    # let(:null_response) { { works: [] } }
    # TODO include triples?
    let(:null_response) { [] }

    it "should report if the doi is missing" do
      work = FactoryGirl.create(:work, :doi => nil)
      result = { error: "query_url is nil." }
      expect(subject.parse_data(result, work_id: work.id)).to eq(error: "query_url is nil.")
    end

    it "should report if there are no events returned by the CiteULike API" do
      body = File.read(fixture_path + 'citeulike_nil.xml')
      result = Hash.from_xml(body)
      expect(subject.parse_data(result, work_id: work.id)).to eq(null_response)
    end

    it "should report if there is an incomplete response returned by the CiteULike API" do
      body = File.read(fixture_path + 'citeulike_incomplete.xml')
      result = { 'data' => body }
      expect(subject.parse_data(result, work_id: work.id)).to eq(null_response)
    end

    it "should report if there are events returned by the CiteULike API" do
      body = File.read(fixture_path + 'citeulike.xml')
      result = Hash.from_xml(body)
      response = subject.parse_data(result, work_id: work.id)

      # TODO
      # event = response[:events].first
      # expect(event[:source_id]).to eq("citeulike")
      # expect(event[:work_id]).to eq(work.pid)
      # expect(event[:total]).to eq(25)
      # expect(event[:readers]).to eq(25)
      # expect(event[:events_url]).to eq(subject.get_events_url(work_id: work.id))
      # expect(event[:months].length).to eq(21)
      # expect(event[:months].first).to eq(year: 2006, month: 6, total: 2, readers: 2)

      # expect(response[:works].length).to eq(25)
      # related_work = response[:works].first
      # expect(related_work['URL']).to eq("http://www.citeulike.org/user/dbogartoit")
      # expect(related_work['author']).to eq([{"given"=>"dbogartoit"}])
      # expect(related_work['title']).to eq("CiteULike bookmarks for user dbogartoit")
      # expect(related_work['container-title']).to eq("CiteULike")
      # expect(related_work['issued']).to eq("date-parts"=>[[2006, 6, 13]])
      # expect(related_work['type']).to eq("entry")
      # expect(related_work["timestamp"]).to eq("2006-06-13T16:14:19Z")
      # expect(related_work["related_works"]).to eq([{"pid"=> work.pid, "source_id"=>"citeulike", "relation_type_id"=>"bookmarks"}])

      expect(response.length).to eq(25)
      
      expect(response.first).to eq({"subject" => "http://www.citeulike.org/user/dbogartoit",
                                    "object" => work.pid,
                                    "relation" => "bookmarks",
                                    "source" => "citeulike",
                                    "occurred_at" => "2006-06-13T16:14:19Z"})
 
      # TODO
      # extra = event[:extra].first
      # expect(extra[:event_time]).to eq("2006-06-13T16:14:19Z")
      # expect(extra[:event_url]).to eq(extra[:event]['link']['url'])
    end

    it "should report if there is one event returned by the CiteULike API" do
      body = File.read(fixture_path + 'citeulike_one.xml')
      result = Hash.from_xml(body)
      response = subject.parse_data(result, work_id: work.id)

      # event = response[:events].first
      # expect(event[:source_id]).to eq("citeulike")
      # expect(event[:work_id]).to eq(work.pid)
      # expect(event[:total]).to eq(1)
      # expect(event[:readers]).to eq(1)
      # expect(event[:events_url]).to eq(subject.get_events_url(work_id: work.id))
      # expect(event[:months].length).to eq(1)
      # expect(event[:months].first).to eq(year: 2006, month: 6, total: 1, readers: 1)

      # expect(response[:works].length).to eq(1)
      # related_work = response[:works].first
      # expect(related_work['URL']).to eq("http://www.citeulike.org/user/dbogartoit")
      # expect(related_work['author']).to eq([{"given"=>"dbogartoit"}])
      # expect(related_work['title']).to eq("CiteULike bookmarks for user dbogartoit")
      # expect(related_work['container-title']).to eq("CiteULike")
      # expect(related_work['issued']).to eq("date-parts"=>[[2006, 6, 13]])
      # expect(related_work['type']).to eq("entry")
      # expect(related_work["timestamp"]).to eq("2006-06-13T16:14:19Z")
      # expect(related_work["related_works"]).to eq([{"pid"=> work.pid, "source_id"=>"citeulike", "relation_type_id"=>"bookmarks"}])

      expect(response.length).to eq(1)
      
      expect(response.first).to eq({"subject" => "http://www.citeulike.org/user/dbogartoit",
                                    "object" => work.pid,
                                    "relation" => "bookmarks",
                                    "source" => "citeulike",
                                    "occurred_at" => "2006-06-13T16:14:19Z"})


      # expect(related_work["timestamp"]).to eq("2006-06-13T16:14:19Z")
      # extra = event[:extra].first
      # expect(extra[:event_time]).to eq("2006-06-13T16:14:19Z")
      # expect(extra[:event_url]).to eq(extra[:event]['link']['url'])
    end

    it "should catch timeout errors with the CiteULike API" do
      result = { error: "the server responded with status 408 for http://www.citeulike.org/api/posts/for/doi/#{work.doi_escaped}", status: 408 }
      response = subject.parse_data(result, work_id: work.id)
      expect(response).to eq(result)
    end
  end
end
