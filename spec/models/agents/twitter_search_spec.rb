require 'rails_helper'

describe TwitterSearch, type: :model, vcr: true do
  subject { FactoryGirl.create(:twitter_search) }

  context "lookup access token" do
    let(:auth) { ActionController::HttpAuthentication::Basic.encode_credentials(subject.api_key, subject.api_secret) }

    it "should make the right API call" do
      subject.access_token = nil
      stub = stub_request(:post, subject.authentication_url)
             .with(:body => "grant_type=client_credentials", :headers => { :authorization => auth })
             .to_return(:body => File.read(fixture_path + 'twitter_auth.json'))
      expect(subject.get_access_token).not_to be false
      expect(stub).to have_been_requested
      expect(subject.access_token).to eq("AAAAAAAAAAAAAAAAAAAAACS6XQAAAAAAc7aBSzqxeYuzho78VPeXw4md79A%3DuWsDmuGGhl0tOQJuNZAl37MN6tiTiar7U8tHQkBGbkk1rvlNqk")
    end

    it "should look up access token if blank" do
      subject.access_token = nil
      work = FactoryGirl.create(:work, :doi => "10.1371/journal.pone.0043007", :canonical_url => "http://www.plosone.org/work/info%3Adoi%2F10.1371%2Fjournal.pone.0043007")
      stub_auth = stub_request(:post, subject.authentication_url)
                  .with(:headers => { :authorization => auth }, :body => "grant_type=client_credentials")
                  .to_return(:body => File.read(fixture_path + 'twitter_auth.json'))
      stub = stub_request(:get, subject.get_query_url(work_id: work.id)).to_return(:status => [408])

      response = subject.get_data(work_id: work.id, source_id: subject.id)
      expect(response[:error]).not_to be_nil
      expect(stub_auth).to have_been_requested
      expect(stub).to have_been_requested
    end
  end

  context "lookup canonical URL" do
    it "should look up canonical URL if there is no work url" do
      work = FactoryGirl.create(:work, pid: "http://doi.org/10.1371/journal.pone.0043007", doi: "10.1371/journal.pone.0043007", :canonical_url => nil)
      report = FactoryGirl.create(:fatal_error_report_with_admin_user)
      lookup_stub = stub_request(:get, work.pid).to_return(:status => 404)
      response = subject.get_data(work_id: work.id)
      expect(lookup_stub).to have_been_requested
    end

    it "should not look up canonical URL if there is work url" do
      work = FactoryGirl.create(:work, :doi => "10.1371/journal.pone.0043007", :canonical_url => "http://www.plosone.org/work/info%3Adoi%2F10.1371%2Fjournal.pone.0043007")
      lookup_stub = stub_request(:get, work.canonical_url).to_return(:status => 200, :headers => { 'Location' => work.canonical_url })
      stub = stub_request(:get, subject.get_query_url(work_id: work.id)).to_return(:body => File.read(fixture_path + 'twitter_search_nil.json'))
      response = subject.get_data(work_id: work.id)
      expect(lookup_stub).not_to have_been_requested
      expect(stub).to have_been_requested
    end
  end

  context "get_data" do
    it "should report that there are no events if the doi and canonical_url are missing" do
      work = FactoryGirl.create(:work, doi: nil, canonical_url: nil)
      expect(subject.get_data(work_id: work.id)).to eq({})
    end

    it "should report if there are no events and event_count returned by the Twitter Search API" do
      work = FactoryGirl.create(:work_with_tweets, :doi => "10.1371/journal.pone.0000000", :canonical_url => "http://www.plosone.org/work/info%3Adoi%2F10.1371%2Fjournal.pmed.0000000")
      body = File.read(fixture_path + 'twitter_search_nil.json', encoding: 'UTF-8')
      stub = stub_request(:get, subject.get_query_url(work_id: work.id)).to_return(:body => body)
      response = subject.get_data(work_id: work.id)
      expect(response).to eq(JSON.parse(body))
      expect(stub).to have_been_requested
    end

    it "should report if there are events and event_count returned by the Twitter Search API" do
      work = FactoryGirl.create(:work_with_tweets, :doi => "10.1371/journal.pmed.0020124", :canonical_url => "http://www.plosmedicine.org/work/info%3Adoi%2F10.1371%2Fjournal.pmed.0020124")
      body = File.read(fixture_path + 'twitter_search.json', encoding: 'UTF-8')
      stub = stub_request(:get, subject.get_query_url(work_id: work.id)).to_return(:body => body)
      response = subject.get_data(work_id: work.id)
      expect(response).to eq(JSON.parse(body))
      expect(stub).to have_been_requested
    end

    it "should catch errors with the Twitter Search API" do
      work = FactoryGirl.create(:work_with_tweets, :doi => "10.1371/journal.pone.0000001", :canonical_url => "http://www.plosone.org/work/info%3Adoi%2F10.1371%2Fjournal.pmed.0000001")
      stub = stub_request(:get, subject.get_query_url(work_id: work.id)).to_return(:status => [408])
      response = subject.get_data(work_id: work.id, agent_id: subject.id)
      expect(response).to eq(error: "the server responded with status 408 for https://api.twitter.com/1.1/search/tweets.json?q=#{subject.get_query_string(work_id: work.id)}&count=100&include_entities=1&result_type=recent", :status=>408)
      expect(stub).to have_been_requested
      expect(Notification.count).to eq(1)
      notification = Notification.first
      expect(notification.class_name).to eq("Net::HTTPRequestTimeOut")
      expect(notification.status).to eq(408)
      expect(notification.agent_id).to eq(subject.id)
    end
  end

  context "parse_data" do
    it "should report if there are no events and event_count returned by the Twitter Search API" do
      work = FactoryGirl.create(:work_with_tweets, :doi => "10.1371/journal.pone.0000000", :canonical_url => "http://www.plosone.org/work/info%3Adoi%2F10.1371%2Fjournal.pmed.0000000")
      body = File.read(fixture_path + 'twitter_search_nil.json', encoding: 'UTF-8')
      result = JSON.parse(body)
      expect(subject.parse_data(result, work_id: work.id)).to eq(works: [], events: [{ source_id: "twitter", work_id: work.pid, comments: 0, total: 0, events_url: {}, extra: [], months: [] }])
    end

    it "should report if there are events and event_count returned by the Twitter Search API" do
      work = FactoryGirl.create(:work_with_tweets, :doi => "10.1371/journal.pmed.0020124", published_on: "2014-01-01")
      body = File.read(fixture_path + 'twitter_search.json', encoding: 'UTF-8')
      result = JSON.parse(body)
      response = subject.parse_data(result, work_id: work.id)

      event = response[:events].first
      expect(event[:total]).to eq(8)
      expect(event[:comments]).to eq(8)
      expect(event[:events_url]).to eq("https://twitter.com/search?q=#{subject.get_query_string(work_id: work.id)}&f=realtime")
      expect(event[:months].length).to eq(1)
      expect(event[:months].first).to eq(year: 2014, month: 1, total: 8, comments: 8)

      expect(response[:works].length).to eq(8)
      related_work = response[:works].first
      expect(related_work['author']).to eq([{"family"=>"Champions Everywhere", "given"=>""}])
      expect(related_work['title']).to eq("A bit technical but worth a read: randomised medical control studies may be almost entirely false:... http://t.co/ohldzDxNiq")
      expect(related_work['container-title']).to eq("Twitter")
      expect(related_work['issued']).to eq("date-parts"=>[[2014, 1, 11]])
      expect(related_work['type']).to eq("personal_communication")
      expect(related_work['URL']).to eq("http://twitter.com/ChampsEvrywhere/status/422039629882089472")
      expect(related_work['timestamp']).to eq("2014-01-11T16:17:43Z")
      expect(related_work['related_works']).to eq([{"pid"=> work.pid, "source_id"=>"twitter", "relation_type_id"=>"discusses"}])

      extra = event[:extra].first
      expect(extra[:event_time]).to eq("2014-01-11T16:17:43Z")
      expect(extra[:event_url]).to eq("http://twitter.com/ChampsEvrywhere/status/422039629882089472")
      expect(extra[:event][:text]).to eq("A bit technical but worth a read: randomised medical control studies may be almost entirely false:... http://t.co/ohldzDxNiq")
    end

    it "should catch timeout errors with the Twitter Search API" do
      work = FactoryGirl.create(:work, :doi => "10.2307/683422")
      result = { error: "the server responded with status 408 for https://api.twitter.com/1.1/search/tweets.json?count=100&include_entities=1&q=#{subject.get_query_string(work_id: work.id)}&result_type=mixed", status: 408 }
      response = subject.parse_data(result, work_id: work.id)
      expect(response).to eq(result)
    end
  end
end