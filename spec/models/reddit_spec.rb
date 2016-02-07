require 'rails_helper'

describe Reddit, type: :model, vcr: true do
  subject { FactoryGirl.create(:reddit) }

  let(:work) { FactoryGirl.create(:work, pid: "http://doi.org/10.1371/journal.ppat.0008776", doi: "10.1371/journal.ppat.0008776", canonical_url: "http://www.plosone.org/article/info:doi/10.1371/journal.ppat.0008776") }

  context "get_data" do
    it "should report that there are no events if the doi and canonical_url are missing" do
      work = FactoryGirl.create(:work, doi: nil, canonical_url: nil)
      expect(subject.get_data(work_id: work.id)).to eq({})
    end

    it "should report if there are no events returned by the Reddit API" do
      work = FactoryGirl.create(:work, doi: "10.1371/journal.pone.0044294", canonical_url: "")
      response = subject.get_data(work_id: work.id)
      expect(response).to eq("kind"=>"Listing", "data"=>{"facets"=>{}, "modhash"=>"", "children"=>[], "after"=>nil, "before"=>nil})
    end

    it "should report if there are events returned by the Reddit API" do
      response = subject.get_data(work_id: work.id)
      expect(response).to eq("kind"=>"Listing", "data"=>{"facets"=>{}, "modhash"=>"", "children"=>[], "after"=>nil, "before"=>nil})
    end

    it "should catch errors with the Reddit API" do
      work = FactoryGirl.create(:work, :doi => "10.1371/journal.pone.0000001")
      stub = stub_request(:get, subject.get_query_url(work_id: work.id)).to_return(:status => [408])
      response = subject.get_data(work_id: work, agent_id: subject.id)
      expect(response).to eq(error: "the server responded with status 408 for http://www.reddit.com/search.json?q=#{subject.get_query_string(work_id: work.id)}&limit=100", :status=>408)
      expect(stub).to have_been_requested
      expect(Notification.count).to eq(1)
      notification = Notification.first
      expect(notification.class_name).to eq("Net::HTTPRequestTimeOut")
      expect(notification.status).to eq(408)
      expect(notification.agent_id).to eq(subject.id)
    end
  end

  context "parse_data" do
    it "should report if the doi and canonical_url are missing" do
      work = FactoryGirl.create(:work, doi: nil, canonical_url: nil)
      result = {}
      result.extend Hashie::Extensions::DeepFetch
      expect(subject.parse_data(result, work_id: work.id)).to eq(works: [], events: [{ source_id: "reddit", work_id: work.pid, comments: 0, likes: 0, total: 0, events_url: nil, extra: [], days: [], months: [] }])
    end

    it "should report if there are no events returned by the Reddit API" do
      work = FactoryGirl.create(:work, :doi => "10.1371/journal.pone.0044294")
      body = File.read(fixture_path + 'reddit_nil.json', encoding: 'UTF-8')
      result = JSON.parse(body)
      result.extend Hashie::Extensions::DeepFetch
      response = subject.parse_data(result, work_id: work.id)
      expect(response).to eq(works: [], events: [{ source_id: "reddit", work_id: work.pid, comments: 0, likes: 0, total: 0, events_url: nil, extra: [], days: [], months: [] }])
    end

    it "should report if there are events returned by the Reddit API" do
      work = FactoryGirl.create(:work, :doi => "10.1371/journal.pone.0008776", published_on: "2013-05-03")
      body = File.read(fixture_path + 'reddit.json', encoding: 'UTF-8')
      result = JSON.parse(body)
      result.extend Hashie::Extensions::DeepFetch
      response = subject.parse_data(result, work_id: work.id)

      event = response[:events].first
      expect(event[:total]).to eq(1171)
      expect(event[:likes]).to eq(1013)
      expect(event[:comments]).to eq(158)
      expect(event[:events_url]).to eq("http://www.reddit.com/search?q=#{subject.get_query_string(work_id: work.id)}")
      expect(event[:days].length).to eq(3)
      expect(event[:days].first).to eq(year: 2013, month: 5, day: 7, total: 1)
      expect(event[:months].length).to eq(2)
      expect(event[:months].first).to eq(year: 2013, month: 5, total: 2)

      expect(response[:works].length).to eq(3)
      related_work = response[:works].first
      expect(related_work['author']).to eq([{"family"=>"Jjberg2", "given"=>""}])
      expect(related_work['title']).to eq("AskScience AMA: We are the authors of a recent paper on genetic genealogy and relatedness among the people of Europe. Ask us anything about our paper!")
      expect(related_work['container-title']).to eq("Reddit")
      expect(related_work['issued']).to eq("date-parts"=>[[2013, 5, 15]])
      expect(related_work['timestamp']).to eq("2013-05-15T17:06:24Z")
      expect(related_work['type']).to eq("personal_communication")

      extra = event[:extra].first
      expect(extra[:event_time]).to eq("2013-05-15T17:06:24Z")
      expect(extra[:event_url]).to eq(extra[:event]['url'])
      expect(extra[:event_csl]['author']).to eq([{"family"=>"Jjberg2", "given"=>""}])
      expect(extra[:event_csl]['title']).to eq("AskScience AMA: We are the authors of a recent paper on genetic genealogy and relatedness among the people of Europe. Ask us anything about our paper!")
      expect(extra[:event_csl]['container-title']).to eq("Reddit")
      expect(extra[:event_csl]['issued']).to eq("date-parts"=>[[2013, 5, 15]])
      expect(extra[:event_csl]['type']).to eq("personal_communication")
    end

    it "should catch timeout errors with the Reddit API" do
      work = FactoryGirl.create(:work, :doi => "10.2307/683422")
      result = { error: "the server responded with status 408 for http://www.reddit.com/search.json?q=#{subject.get_query_string(work_id: work.id)}", status: 408 }
      response = subject.parse_data(result, work_id: work.id)
      expect(response).to eq(result)
    end
  end
end
