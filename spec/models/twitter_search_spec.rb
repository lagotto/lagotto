require 'rails_helper'

describe TwitterSearch, :type => :model do
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
      article = FactoryGirl.create(:article, :doi => "10.1371/journal.pone.0043007", :canonical_url => "http://www.plosone.org/article/info%3Adoi%2F10.1371%2Fjournal.pone.0043007")
      stub_auth = stub_request(:post, subject.authentication_url)
                  .with(:headers => { :authorization => auth }, :body => "grant_type=client_credentials")
                  .to_return(:body => File.read(fixture_path + 'twitter_auth.json'))
      stub = stub_request(:get, subject.get_query_url(article)).to_return(:status => [408])

      response = subject.get_data(article, source_id: subject.id)
      expect(response[:error]).not_to be_nil
      expect(stub_auth).to have_been_requested
      expect(stub).to have_been_requested
    end
  end

  context "lookup canonical URL" do
    it "should look up canonical URL if there is no article url" do
      article = FactoryGirl.create(:article, :doi => "10.1371/journal.pone.0043007", :canonical_url => nil)
      report = FactoryGirl.create(:fatal_error_report_with_admin_user)
      lookup_stub = stub_request(:get, article.doi_as_url).to_return(:status => 404)
      response = subject.get_data(article)
      expect(lookup_stub).to have_been_requested
    end

    it "should not look up canonical URL if there is article url" do
      article = FactoryGirl.create(:article, :doi => "10.1371/journal.pone.0043007", :canonical_url => "http://www.plosone.org/article/info%3Adoi%2F10.1371%2Fjournal.pone.0043007")
      lookup_stub = stub_request(:get, article.canonical_url).to_return(:status => 200, :headers => { 'Location' => article.canonical_url })
      stub = stub_request(:get, subject.get_query_url(article)).to_return(:body => File.read(fixture_path + 'cross_ref_nil.xml'))
      response = subject.get_data(article)
      expect(lookup_stub).not_to have_been_requested
      expect(stub).to have_been_requested
    end
  end

  context "get_data" do
    it "should report that there are no events if the doi is missing" do
      article = FactoryGirl.build(:article, :doi => nil)
      expect(subject.get_data(article)).to eq({})
    end

    it "should report if there are no events and event_count returned by the Twitter Search API" do
      article = FactoryGirl.create(:article_with_tweets, :doi => "10.1371/journal.pone.0000000", :canonical_url => "http://www.plosone.org/article/info%3Adoi%2F10.1371%2Fjournal.pmed.0000000")
      body = File.read(fixture_path + 'twitter_search_nil.json', encoding: 'UTF-8')
      stub = stub_request(:get, subject.get_query_url(article)).to_return(:body => body)
      response = subject.get_data(article)
      expect(response).to eq(JSON.parse(body))
      expect(stub).to have_been_requested
    end

    it "should report if there are events and event_count returned by the Twitter Search API" do
      article = FactoryGirl.create(:article_with_tweets, :doi => "10.1371/journal.pmed.0020124", :canonical_url => "http://www.plosmedicine.org/article/info%3Adoi%2F10.1371%2Fjournal.pmed.0020124")
      body = File.read(fixture_path + 'twitter_search.json', encoding: 'UTF-8')
      stub = stub_request(:get, subject.get_query_url(article)).to_return(:body => body)
      response = subject.get_data(article)
      expect(response).to eq(JSON.parse(body))
      expect(stub).to have_been_requested
    end

    it "should catch errors with the Twitter Search API" do
      article = FactoryGirl.create(:article_with_tweets, :doi => "10.1371/journal.pone.0000001", :canonical_url => "http://www.plosone.org/article/info%3Adoi%2F10.1371%2Fjournal.pmed.0000001")
      stub = stub_request(:get, subject.get_query_url(article)).to_return(:status => [408])
      response = subject.get_data(article, options = { :source_id => subject.id })
      expect(response).to eq(error: "the server responded with status 408 for https://api.twitter.com/1.1/search/tweets.json?q=%2210.1371%252Fjournal.pone.0000001%22%20OR%20%22http://www.plosone.org/article/info%253Adoi%252F10.1371%252Fjournal.pmed.0000001%22&count=100&include_entities=1&result_type=recent", :status=>408)
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
      article = FactoryGirl.create(:article_with_tweets, :doi => "10.1371/journal.pone.0000000", :canonical_url => "http://www.plosone.org/article/info%3Adoi%2F10.1371%2Fjournal.pmed.0000000")
      body = File.read(fixture_path + 'twitter_search_nil.json', encoding: 'UTF-8')
      result = JSON.parse(body)
      expect(subject.parse_data(result, article)).to eq(events: [], :events_by_day=>[], :events_by_month=>[], event_count: 0, events_url: "https://twitter.com/search?q=%2210.1371%252Fjournal.pone.0000000%22%20OR%20%22http://www.plosone.org/article/info%253Adoi%252F10.1371%252Fjournal.pmed.0000000%22&f=realtime", event_metrics: { pdf: nil, html: nil, shares: nil, groups: nil, comments: 0, likes: nil, citations: nil, total: 0 })
    end

    it "should report if there are events and event_count returned by the Twitter Search API" do
      article = FactoryGirl.build(:article_with_tweets, :doi => "10.1371/journal.pmed.0020124", published_on: "2014-01-01")
      body = File.read(fixture_path + 'twitter_search.json', encoding: 'UTF-8')
      result = JSON.parse(body)
      response = subject.parse_data(result, article)
      expect(response[:events].length).to eq(8)
      expect(response[:event_count]).to eq(8)
      expect(response[:event_metrics][:comments]).to eq(8)
      expect(response[:events_url]).to eq("https://twitter.com/search?q=%2210.1371%252Fjournal.pmed.0020124%22%20OR%20%22%22&f=realtime")

      expect(response[:events_by_day].length).to eq(6)
      expect(response[:events_by_day].first).to eq(year: 2014, month: 1, day: 6, total: 1)
      expect(response[:events_by_month].length).to eq(1)
      expect(response[:events_by_month].first).to eq(year: 2014, month: 1, total: 8)

      event = response[:events].first

      expect(event[:event_csl]['author']).to eq([{"family"=>"Champions Everywhere", "given"=>""}])
      expect(event[:event_csl]['title']).to eq("A bit technical but worth a read: randomised medical control studies may be almost entirely false:... http://t.co/ohldzDxNiq")
      expect(event[:event_csl]['container-title']).to eq("Twitter")
      expect(event[:event_csl]['issued']).to eq("date-parts"=>[[2014, 1, 11]])
      expect(event[:event_csl]['type']).to eq("personal_communication")

      expect(event[:event_url]).to eq("http://twitter.com/ChampsEvrywhere/status/422039629882089472")
      expect(event[:event_time]).to eq("2014-01-11T16:17:43Z")
    end

    it "should catch timeout errors with the Twitter Search API" do
      article = FactoryGirl.create(:article, :doi => "10.2307/683422")
      result = { error: "the server responded with status 408 for https://api.twitter.com/1.1/search/tweets.json?count=100&include_entities=1&q=#{CGI.escape(article.doi_escaped)}&result_type=mixed", status: 408 }
      response = subject.parse_data(result, article)
      expect(response).to eq(result)
    end
  end
end
