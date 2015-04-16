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
      stub = stub_request(:get, subject.get_query_url(work)).to_return(:status => [408])

      response = subject.get_data(work, source_id: subject.id)
      expect(response[:error]).not_to be_nil
      expect(stub_auth).to have_been_requested
      expect(stub).to have_been_requested
    end
  end

  context "lookup canonical URL" do
    it "should look up canonical URL if there is no work url" do
      work = FactoryGirl.create(:work, :doi => "10.1371/journal.pone.0043007", :canonical_url => nil)
      report = FactoryGirl.create(:fatal_error_report_with_admin_user)
      lookup_stub = stub_request(:get, work.doi_as_url).to_return(:status => 404)
      response = subject.get_data(work)
      expect(lookup_stub).to have_been_requested
    end

    it "should not look up canonical URL if there is work url" do
      work = FactoryGirl.create(:work, :doi => "10.1371/journal.pone.0043007", :canonical_url => "http://www.plosone.org/work/info%3Adoi%2F10.1371%2Fjournal.pone.0043007")
      lookup_stub = stub_request(:get, work.canonical_url).to_return(:status => 200, :headers => { 'Location' => work.canonical_url })
      stub = stub_request(:get, subject.get_query_url(work)).to_return(:body => File.read(fixture_path + 'cross_ref_nil.xml'))
      response = subject.get_data(work)
      expect(lookup_stub).not_to have_been_requested
      expect(stub).to have_been_requested
    end
  end

  context "get_data" do
    it "should report that there are no events if the doi and canonical_url are missing" do
      work = FactoryGirl.build(:work, doi: nil, canonical_url: nil)
      expect(subject.get_data(work)).to eq({})
    end

    it "should report if there are no events and event_count returned by the Twitter Search API" do
      work = FactoryGirl.create(:work_with_tweets, :doi => "10.1371/journal.pone.0000000", :canonical_url => "http://www.plosone.org/work/info%3Adoi%2F10.1371%2Fjournal.pmed.0000000")
      body = File.read(fixture_path + 'twitter_search_nil.json', encoding: 'UTF-8')
      stub = stub_request(:get, subject.get_query_url(work)).to_return(:body => body)
      response = subject.get_data(work)
      expect(response).to eq(JSON.parse(body))
      expect(stub).to have_been_requested
    end

    it "should report if there are events and event_count returned by the Twitter Search API" do
      work = FactoryGirl.create(:work_with_tweets, :doi => "10.1371/journal.pmed.0020124", :canonical_url => "http://www.plosmedicine.org/work/info%3Adoi%2F10.1371%2Fjournal.pmed.0020124")
      body = File.read(fixture_path + 'twitter_search.json', encoding: 'UTF-8')
      stub = stub_request(:get, subject.get_query_url(work)).to_return(:body => body)
      response = subject.get_data(work)
      expect(response).to eq(JSON.parse(body))
      expect(stub).to have_been_requested
    end

    it "should catch errors with the Twitter Search API" do
      work = FactoryGirl.create(:work_with_tweets, :doi => "10.1371/journal.pone.0000001", :canonical_url => "http://www.plosone.org/work/info%3Adoi%2F10.1371%2Fjournal.pmed.0000001")
      stub = stub_request(:get, subject.get_query_url(work)).to_return(:status => [408])
      response = subject.get_data(work, options = { :source_id => subject.id })
      expect(response).to eq(error: "the server responded with status 408 for https://api.twitter.com/1.1/search/tweets.json?q=#{subject.get_query_string(work)}&count=100&include_entities=1&result_type=recent", :status=>408)
      expect(stub).to have_been_requested
      expect(Alert.count).to eq(1)
      alert = Alert.first
      expect(alert.class_name).to eq("Net::HTTPRequestTimeOut")
      expect(alert.status).to eq(408)
      expect(alert.source_id).to eq(subject.id)
    end
  end

  context "parse_data" do
    it "should report if there are no events and event_count returned by the Twitter Search API" do
      work = FactoryGirl.create(:work_with_tweets, :doi => "10.1371/journal.pone.0000000", :canonical_url => "http://www.plosone.org/work/info%3Adoi%2F10.1371%2Fjournal.pmed.0000000")
      body = File.read(fixture_path + 'twitter_search_nil.json', encoding: 'UTF-8')
      result = JSON.parse(body)
      expect(subject.parse_data(result, work)).to eq(works: [], events: { comments: 0, total: 0, events_url: "https://twitter.com/search?q=%22#{work.doi}%22+OR+%22#{work.canonical_url}%22&f=realtime", extra: [], days: [], months: [] })
    end

    it "should report if there are events and event_count returned by the Twitter Search API" do
      work = FactoryGirl.build(:work_with_tweets, :doi => "10.1371/journal.pmed.0020124", published_on: "2014-01-01")
      body = File.read(fixture_path + 'twitter_search.json', encoding: 'UTF-8')
      result = JSON.parse(body)
      response = subject.parse_data(result, work)
      expect(response[:works].length).to eq(8)
      expect(response[:events][:total]).to eq(8)
      expect(response[:events][:comments]).to eq(8)
      expect(response[:events][:events_url]).to eq("https://twitter.com/search?q=#{subject.get_query_string(work)}&f=realtime")
      expect(response[:events][:days].length).to eq(6)
      expect(response[:events][:days].first).to eq(year: 2014, month: 1, day: 6, total: 1, comments: 1)
      expect(response[:events][:months].length).to eq(1)
      expect(response[:events][:months].first).to eq(year: 2014, month: 1, total: 8, comments: 8)

      event = response[:works].first
      expect(event['author']).to eq([{"family"=>"Champions Everywhere", "given"=>""}])
      expect(event['title']).to eq("A bit technical but worth a read: randomised medical control studies may be almost entirely false:... http://t.co/ohldzDxNiq")
      expect(event['container-title']).to eq("Twitter")
      expect(event['issued']).to eq("date-parts"=>[[2014, 1, 11]])
      expect(event['type']).to eq("personal_communication")
      expect(event['URL']).to eq("http://twitter.com/ChampsEvrywhere/status/422039629882089472")
      expect(event['timestamp']).to eq("2014-01-11T16:17:43Z")
      expect(event['related_works']).to eq([{"related_work"=> work.pid, "source"=>"twitter_search", "relation_type"=>"discusses"}])
    end

    it "should catch timeout errors with the Twitter Search API" do
      work = FactoryGirl.create(:work, :doi => "10.2307/683422")
      result = { error: "the server responded with status 408 for https://api.twitter.com/1.1/search/tweets.json?count=100&include_entities=1&q=#{subject.get_query_string(work)}&result_type=mixed", status: 408 }
      response = subject.parse_data(result, work)
      expect(response).to eq(result)
    end
  end
end
