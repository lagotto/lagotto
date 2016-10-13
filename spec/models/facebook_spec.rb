require 'rails_helper'

describe Facebook, type: :model, vcr: true do
  subject { FactoryGirl.create(:facebook) }
  let(:headers) do
    { 'Accept'=>'application/json',
      'User-Agent'=>"Lagotto - http://#{ENV['SERVERNAME']}" }
  end

  context "lookup access token" do
    it "should make the right API call" do
      subject.access_token = nil
      stub = stub_request(:get, subject.get_authentication_url).to_return(:body => File.read(fixture_path + 'facebook_auth.txt'))
      expect(subject.get_access_token).not_to be false
      expect(stub).to have_been_requested
      expect(subject.access_token).to eq("778123482473896|xQ0RGAHG6k8VUZrliyHgIIkwZYM")
    end

    it "should look up access token if blank" do
      subject.access_token = nil
      work = FactoryGirl.create(:work, :doi => "10.1371/journal.pone.0043007", :canonical_url => "http://www.plosone.org/article/info%3Adoi%2F10.1371%2Fjournal.pone.0043007")
      stub_auth = stub_request(:get, subject.get_authentication_url).to_return(:body => File.read(fixture_path + 'facebook_auth.txt'))
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
      work = FactoryGirl.create(:work, :doi => "10.1371/journal.pone.0043007", :canonical_url => "http://www.plosone.org/article/info%3Adoi%2F10.1371%2Fjournal.pone.0043007")
      lookup_stub = stub_request(:get, work.canonical_url)
                    .with(:headers => headers)
                    .to_return(:status => 200, :headers => { 'Location' => work.canonical_url })
      stub = stub_request(:get, subject.get_query_url(work)).to_return(:body => File.read(fixture_path + 'cross_ref_nil.xml'))
      response = subject.get_data(work)
      expect(lookup_stub).not_to have_been_requested
      expect(stub).to have_been_requested
    end
  end

  context "get_data" do
    it "should report that there are no events if the doi and canonical URL are missing" do
      work = FactoryGirl.create(:work, doi: nil, canonical_url: nil)
      expect(subject.get_data(work)).to eq({})
    end

    it "should report if there are no events returned by the Facebook API" do
      work = FactoryGirl.create(:work, :canonical_url => "http://www.plosone.org/article/info%3Adoi%2F10.1371%2Fjournal.pone.0000001")
      body = File.read(fixture_path + 'facebook_nil.json')
      stub = stub_request(:get, subject.get_query_url(work))
             .with(:headers => headers).to_return(:body => body)
      response = subject.get_data(work)
      expect(response).to eq(JSON.parse(body))
      expect(stub).to have_been_requested
    end

    it "should report if there are events returned by the Facebook API" do
      work = FactoryGirl.create(:work, :canonical_url => "http://www.plosmedicine.org/article/info:doi/10.1371/journal.pmed.0020124")
      body = File.read(fixture_path + 'facebook.json')
      stub = stub_request(:get, subject.get_query_url(work))
             .with(:headers => headers).to_return(:body => body)
      response = subject.get_data(work)
      expect(response).to eq(JSON.parse(body))
      expect(stub).to have_been_requested
    end

    it "should catch authorization errors with the Facebook API" do
      work = FactoryGirl.create(:work, :canonical_url => "http://www.plosmedicine.org/article/info:doi/10.1371/journal.pmed.0020124")
      stub = stub_request(:get, subject.get_query_url(work))
             .with(:headers => headers)
             .to_return(:body => File.read(fixture_path + 'facebook_error.json'), :status => [401])
      response = subject.get_data(work, options = { :source_id => subject.id })
      expect(response).to eq(error: "the server responded with status 401 for #{subject.get_query_url(work)}", status: 401)
      expect(stub).to have_been_requested
      expect(Alert.count).to eq(1)
      alert = Alert.first
      expect(alert.class_name).to eq("Net::HTTPUnauthorized")
      expect(alert.status).to eq(401)
      expect(alert.source_id).to eq(subject.id)
    end
  end

  context "parse_data" do

    let(:work) { FactoryGirl.create(:work, :canonical_url => "http://www.plosmedicine.org/article/info:doi/10.1371/journal.pmed.0020124") }

    it "should report if the doi and canonical URL are missing" do
      work = FactoryGirl.create(:work, doi: nil, canonical_url: nil)
      result = {}
      result.extend Hashie::Extensions::DeepFetch
      expect(subject.parse_data(result, work)).to eq(events: { source: "facebook", work: work.pid, readers: 0, comments: 0, likes: 0, total: 0, extra: {"comment_count"=>0, "share_count"=>0, "like_count"=>0, "url"=> nil,"total_count"=>0} })
    end

    it "should report if there are no events returned by the Facebook API" do
      body = File.read(fixture_path + 'facebook_nil.json')
      result = JSON.parse(body)
      result.extend Hashie::Extensions::DeepFetch
      response = subject.parse_data(result, work)
      expect(response[:events][:total]).to eq(0)
      extra = response[:events][:extra]
      expect(extra).to eq("comment_count"=>0, "share_count"=>0, "like_count"=>0, "url"=>"http://www.plosone.org/article/info:doi/10.1371/journal.pone.0000001", "total_count"=>0)
    end

    it "should report if there are events returned by the Facebook API" do
      body = File.read(fixture_path + 'facebook.json')
      result = JSON.parse(body)
      result.extend Hashie::Extensions::DeepFetch
      response = subject.parse_data(result, work)
      expect(response[:events][:total]).to eq(9972)
      extra = response[:events][:extra]
      expect(extra).to eq("comment_count"=>0, "share_count"=>9972,"like_count"=>0, "url"=>"http://www.plosmedicine.org/article/info:doi/10.1371/journal.pmed.0020124", "total_count"=>9972)
    end

    it "should catch errors with the Facebook API" do
      result = { error: "the server responded with status 401 for https%3A%2F%2Fgraph.facebook.com%2F2.7%2F%3Faccess_token%3DEXAMPLE%26id%3D%27http%3A%2F%2Fwww.plosmedicine.org%2Farticle%2Finfo%3Adoi%2F#{CGI.escape(work.doi_escaped)}'", status: 408 }
      response = subject.parse_data(result, work)
      expect(response).to eq(result)
    end
  end

  end
