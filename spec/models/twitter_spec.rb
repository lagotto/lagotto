require 'rails_helper'

describe Twitter, type: :model, vcr: true do
  subject { FactoryGirl.create(:twitter) }

  let(:work) { FactoryGirl.create(:work, canonical_url: "http://www.plosone.org/work/info%3Adoi%2F10.1371%2Fjournal.pmed.0020124", published_on: "2012-05-03") }

  context "get_data" do
    it "should report that there are no events if the doi is missing" do
      work = FactoryGirl.create(:work, :doi => nil)
      expect(subject.get_data(work_id: work.id)).to eq({})
    end

    it "should report if there are no events returned by the Twitter API" do
      work = FactoryGirl.create(:work, :doi => "10.1371/journal.pone.0044294")
      body = File.read(fixture_path + 'twitter_nil.json', encoding: 'UTF-8')
      stub = stub_request(:get, subject.get_query_url(work_id: work.id)).to_return(:body => body)
      response = subject.get_data(work_id: work.id)
      expect(response).to eq(JSON.parse(body))
      expect(stub).to have_been_requested
    end

    it "should report if there are events returned by the Twitter API" do
      body = File.read(fixture_path + 'twitter.json')
      stub = stub_request(:get, subject.get_query_url(work_id: work.id)).to_return(:body => body)
      response = subject.get_data(work_id: work.id)
      expect(response).to eq(JSON.parse(body))
      expect(stub).to have_been_requested
    end

    it "should catch errors with the Twitter API" do
      stub = stub_request(:get, subject.get_query_url(work_id: work.id)).to_return(:status => [408])
      response = subject.get_data(work_id: work, agent_id: subject.id)
      expect(response).to eq(error: "the server responded with status 408 for http://example.org?doi=#{work.doi_escaped}", :status=>408)
      expect(stub).to have_been_requested
      expect(Notification.count).to eq(1)
      notification = Notification.first
      expect(notification.class_name).to eq("Net::HTTPRequestTimeOut")
      expect(notification.status).to eq(408)
      expect(notification.agent_id).to eq(subject.id)
    end
  end

  context "parse_data" do
    it "should report if there are no events returned by the Twitter API" do
      body = File.read(fixture_path + 'twitter_nil.json', encoding: 'UTF-8')
      result = JSON.parse(body)
      response = subject.parse_data(result, work_id: work.id)
      expect(response).to eq(works: [], events: [{ source_id: "twitter", work_id: work.pid, comments: 0, total: 0, extra: [], months: [] }])
    end

    it "should report if there are events returned by the Twitter API" do
      body = File.read(fixture_path + 'twitter.json')
      result = JSON.parse(body)
      response = subject.parse_data(result, work_id: work.id)

      event = response[:events].first
      expect(event[:total]).to eq(2)
      expect(event[:months].length).to eq(1)
      expect(event[:months].first).to eq(year: 2012, month: 5, total: 2, comments: 2)

      expect(response[:works].length).to eq(2)
      related_work = response[:works].first
      expect(related_work['author']).to eq([{"given"=>"regrum"}])
      expect(related_work['title']).to eq("Don't be blinded by science http://t.co/YOWRhsXb")
      expect(related_work['container-title']).to eq("Twitter")
      expect(related_work['issued']).to eq("date-parts"=>[[2012, 5, 20]])
      expect(related_work['type']).to eq("personal_communication")
      expect(related_work['URL']).to eq("http://twitter.com/regrum/status/204270013081849857")
      expect(related_work['timestamp']).to eq("2012-05-20T17:59:00Z")
      expect(related_work['related_works']).to eq([{"pid"=> work.pid, "source_id"=>"twitter", "relation_type_id"=>"discusses"}])

      extra = event[:extra].first
      extra = extra[:event]
      expect(extra[:id]).to eq("204270013081849857")
      expect(extra[:text]).to eq("Don't be blinded by science http://t.co/YOWRhsXb")
      expect(extra[:created_at]).to eq("2012-05-20T17:59:00Z")
      expect(extra[:user]).to eq("regrum")
      expect(extra[:user_name]).to eq("regrum")
      expect(extra[:user_profile_image]).to eq("http://a0.twimg.com/profile_images/61215276/regmanic2_normal.JPG")
    end

    it "should catch timeout errors with the Twitter API" do
      work = FactoryGirl.create(:work, :doi => "10.2307/683422")
      result = { error: "the server responded with status 408 for http://example.org?doi=#{work.doi_escaped}", status: 408 }
      response = subject.parse_data(result, work_id: work.id)
      expect(response).to eq(result)
    end
  end
end
