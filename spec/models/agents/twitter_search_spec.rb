require 'rails_helper'

describe TwitterSearch, type: :model, vcr: true do
  let(:work) { FactoryGirl.create(:work) }
  subject { FactoryGirl.create(:twitter_search) }

  context "urls" do
    it "should get_query_url" do
      expect(subject.get_query_url(work_id: work.id)).to eq("https://api.twitter.com/1.1/search/tweets.json?q=%22#{work.doi}%22+OR+%22#{work.canonical_url}%22&count=100&include_entities=1&result_type=recent")
    end

    it "should get_provenance_url" do
      expect(subject.get_provenance_url(work_id: work.id)).to eq("https://twitter.com/search?q=%22#{work.doi}%22+OR+%22#{work.canonical_url}%22&f=realtime")
    end
  end

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

      response = subject.get_data(work_id: work.id, source_id: subject.source_id)
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
      expect(lookup_stub).to have_been_requested.twice()
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
      work = FactoryGirl.create(:work_with_twitter, :doi => "10.1371/journal.pone.0000000", :canonical_url => "http://www.plosone.org/work/info%3Adoi%2F10.1371%2Fjournal.pmed.0000000")
      body = File.read(fixture_path + 'twitter_search_nil.json', encoding: 'UTF-8')
      stub = stub_request(:get, subject.get_query_url(work_id: work.id)).to_return(:body => body)
      response = subject.get_data(work_id: work.id)
      expect(response).to eq(JSON.parse(body))
      expect(stub).to have_been_requested
    end

    it "should report if there are events and event_count returned by the Twitter Search API" do
      work = FactoryGirl.create(:work_with_twitter, :doi => "10.1371/journal.pmed.0020124", :canonical_url => "http://www.plosmedicine.org/work/info%3Adoi%2F10.1371%2Fjournal.pmed.0020124")
      body = File.read(fixture_path + 'twitter_search.json', encoding: 'UTF-8')
      stub = stub_request(:get, subject.get_query_url(work_id: work.id)).to_return(:body => body)
      response = subject.get_data(work_id: work.id)
      expect(response).to eq(JSON.parse(body))
      expect(stub).to have_been_requested
    end

    it "should catch errors with the Twitter Search API" do
      work = FactoryGirl.create(:work_with_twitter, :doi => "10.1371/journal.pone.0000001", :canonical_url => "http://www.plosone.org/work/info%3Adoi%2F10.1371%2Fjournal.pmed.0000001")
      stub = stub_request(:get, subject.get_query_url(work_id: work.id)).to_return(:status => [408])
      response = subject.get_data(work_id: work.id, source_id: subject.source_id)
      expect(response).to eq(error: "the server responded with status 408 for https://api.twitter.com/1.1/search/tweets.json?q=#{subject.get_query_string(work_id: work.id)}&count=100&include_entities=1&result_type=recent", :status=>408)
      expect(stub).to have_been_requested
      expect(Notification.count).to eq(1)
      notification = Notification.first
      expect(notification.class_name).to eq("Net::HTTPRequestTimeOut")
      expect(notification.status).to eq(408)
    end
  end

  context "parse_data" do
    it "should report if there are no events and event_count returned by the Twitter Search API" do
      work = FactoryGirl.create(:work_with_twitter, :doi => "10.1371/journal.pone.0000000", :canonical_url => "http://www.plosone.org/work/info%3Adoi%2F10.1371%2Fjournal.pmed.0000000")
      body = File.read(fixture_path + 'twitter_search_nil.json', encoding: 'UTF-8')
      result = JSON.parse(body)
      expect(subject.parse_data(result, work_id: work.id)).to eq([])
    end

    it "should report if there are events and event_count returned by the Twitter Search API" do
      work = FactoryGirl.create(:work_with_twitter, :doi => "10.1371/journal.pmed.0020124", published_on: "2014-01-01")
      body = File.read(fixture_path + 'twitter_search.json', encoding: 'UTF-8')
      result = JSON.parse(body)
      response = subject.parse_data(result, work_id: work.id)

      expect(response.length).to eq(8)
      expect(response.first[:relation]).to eq("subj_id"=>"http://twitter.com/ChampsEvrywhere/status/422039629882089472",
                                              "obj_id"=>work.pid,
                                              "relation_type_id"=>"discusses",
                                              "provenance_url"=>"https://twitter.com/search?q=%22#{work.doi}%22+OR+%22#{work.canonical_url}%22&f=realtime",
                                              "source_id"=>"twitter")

      expect(response.first[:subj]).to eq("pid"=>"http://twitter.com/ChampsEvrywhere/status/422039629882089472",
                                          "author"=>[{"given"=>"ChampionsEverywhere"}],
                                          "title"=>"A bit technical but worth a read: randomised medical control studies may be almost entirely false:... http://t.co/ohldzDxNiq",
                                          "container-title"=>"Twitter",
                                          "issued"=>"2014-01-11T16:17:43Z",
                                          "URL"=>"http://twitter.com/ChampsEvrywhere/status/422039629882089472",
                                          "type"=>"personal_communication",
                                          "tracked"=>false,
                                          "registration_agency_id"=>"twitter")
    end

    it "should catch timeout errors with the Twitter Search API" do
      work = FactoryGirl.create(:work, :doi => "10.2307/683422")
      result = { error: "the server responded with status 408 for https://api.twitter.com/1.1/search/tweets.json?count=100&include_entities=1&q=#{subject.get_query_string(work_id: work.id)}&result_type=mixed", status: 408 }
      response = subject.parse_data(result, work_id: work.id)
      expect(response).to eq([result])
    end
  end
end
