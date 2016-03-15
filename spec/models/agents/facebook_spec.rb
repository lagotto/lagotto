require 'rails_helper'

describe Facebook, type: :model do
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
      stub = stub_request(:get, subject.get_query_url(work_id: work.id)).to_return(:status => [408])

      response = subject.get_data(work_id: work.id, agent_id: subject.id)
      expect(response[:error]).not_to be_nil
      expect(stub_auth).to have_been_requested
      expect(stub).to have_been_requested
    end
  end

  context "lookup canonical URL" do
    it "should look up canonical URL if there is no work url" do
      work = FactoryGirl.create(:work, :doi => "10.1371/journal.pone.0043007", :canonical_url => nil)
      report = FactoryGirl.create(:fatal_error_report_with_admin_user)
      lookup_stub = stub_request(:get, work.doi_as_url(work.doi)).to_return(:status => [404])
      response = subject.get_data(work_id: work.id)
      expect(lookup_stub).to have_been_requested
    end

    it "should not look up canonical URL if there is work url" do
      work = FactoryGirl.create(:work, :doi => "10.1371/journal.pone.0043007", :canonical_url => "http://www.plosone.org/article/info%3Adoi%2F10.1371%2Fjournal.pone.0043007")
      lookup_stub = stub_request(:get, work.canonical_url)
                    .with(:headers => headers)
                    .to_return(:status => 200, :headers => { 'Location' => work.canonical_url })
      stub = stub_request(:get, subject.get_query_url(work_id: work.id)).to_return(:body => File.read(fixture_path + 'cross_ref_nil.xml'))
      response = subject.get_data(work_id: work.id)
      expect(lookup_stub).not_to have_been_requested
      expect(stub).to have_been_requested
    end
  end

  context "get_data" do
    it "should report that there are no events if the doi and canonical URL are missing" do
      work = FactoryGirl.create(:work, doi: nil, canonical_url: nil)
      expect(subject.get_data(work_id: work.id)).to eq({})
    end

    it "should report if there are no events returned by the Facebook API" do
      work = FactoryGirl.create(:work, :canonical_url => "http://www.plosone.org/article/info%3Adoi%2F10.1371%2Fjournal.pone.0000001")
      body = File.read(fixture_path + 'facebook_nil.json')
      stub = stub_request(:get, subject.get_query_url(work_id: work.id))
             .with(:headers => headers).to_return(:body => body)
      response = subject.get_data(work_id: work.id)
      expect(response).to eq(JSON.parse(body))
      expect(stub).to have_been_requested
    end

    it "should report if there are events returned by the Facebook API" do
      work = FactoryGirl.create(:work, :canonical_url => "http://www.plosmedicine.org/article/info:doi/10.1371/journal.pmed.0020124")
      body = File.read(fixture_path + 'facebook.json')
      stub = stub_request(:get, subject.get_query_url(work_id: work.id))
             .with(:headers => headers).to_return(:body => body)
      response = subject.get_data(work_id: work.id)
      expect(response).to eq(JSON.parse(body))
      expect(stub).to have_been_requested
    end

    it "should catch authorization errors with the Facebook API" do
      work = FactoryGirl.create(:work, :canonical_url => "http://www.plosmedicine.org/article/info:doi/10.1371/journal.pmed.0020124")
      stub = stub_request(:get, subject.get_query_url(work_id: work.id))
             .with(:headers => headers)
             .to_return(:body => File.read(fixture_path + 'facebook_error.json'), :status => [401])
      response = subject.get_data(work_id: work.id, agent_id: subject.id)
      expect(response).to eq(error: "the server responded with status 401 for #{subject.get_query_url(work_id: work.id)}", status: 401)
      expect(stub).to have_been_requested
      expect(Notification.count).to eq(1)
      notification = Notification.first
      expect(notification.class_name).to eq("Net::HTTPUnauthorized")
      expect(notification.status).to eq(401)
      expect(notification.agent_id).to eq(subject.id)
    end
  end

  context "get_data with url_linkstat" do
    subject { FactoryGirl.create(:facebook, url_linkstat: "https://graph.facebook.com/fql?access_token=%{access_token}&q=select url, share_count, like_count, comment_count, click_count, total_count from link_stat where url = '%{query_url}'") }

    it "should report if there are no events returned by the Facebook API" do
      work = FactoryGirl.create(:work, :canonical_url => "http://www.plosone.org/article/info%3Adoi%2F10.1371%2Fjournal.pone.0000001")
      body = File.read(fixture_path + 'facebook_linkstat_nil.json')
      stub = stub_request(:get, subject.get_query_url(work_id: work.id))
             .with(:headers => headers).to_return(:body => body)
      response = subject.get_data(work_id: work.id)
      expect(response).to eq(JSON.parse(body))
      expect(stub).to have_been_requested
    end

    it "should report if there are events returned by the Facebook API" do
      work = FactoryGirl.create(:work, :canonical_url => "http://www.plosmedicine.org/article/info:doi/10.1371/journal.pmed.0020124")
      body = File.read(fixture_path + 'facebook_linkstat.json')
      stub = stub_request(:get, subject.get_query_url(work_id: work.id))
             .with(:headers => headers).to_return(:body => body)
      response = subject.get_data(work_id: work.id)
      expect(response).to eq(JSON.parse(body))
      expect(stub).to have_been_requested
    end

    it "should catch authorization errors with the Facebook API" do
      work = FactoryGirl.create(:work, :canonical_url => "http://www.plosmedicine.org/article/info:doi/10.1371/journal.pmed.0020124")
      stub = stub_request(:get, subject.get_query_url(work_id: work.id))
             .with(:headers => headers)
             .to_return(:body => File.read(fixture_path + 'facebook_error.json'), :status => [401])
      response = subject.get_data(work_id: work.id, agent_id: subject.id)
      expect(response).to eq(error: "the server responded with status 401 for #{subject.get_query_url(work_id: work.id)}", status: 401)
      expect(stub).to have_been_requested
      expect(Notification.count).to eq(1)
      notification = Notification.first
      expect(notification.class_name).to eq("Net::HTTPUnauthorized")
      expect(notification.status).to eq(401)
      expect(notification.agent_id).to eq(subject.id)
    end

    it "should catch timeout errors with the Facebook API" do
      work = FactoryGirl.create(:work, :canonical_url => "http://www.plosmedicine.org/article/info:doi/10.1371/journal.pmed.0020124")
      stub = stub_request(:get, subject.get_query_url(work_id: work.id)).to_return(:status => [408])
      response = subject.get_data(work_id: work.id, agent_id: subject.id)
      expect(response).to eq(error: "the server responded with status 408 for #{subject.get_query_url(work_id: work.id)}", :status=>408)
      expect(stub).to have_been_requested
      expect(Notification.count).to eq(1)
      notification = Notification.first
      expect(notification.class_name).to eq("Net::HTTPRequestTimeOut")
      expect(notification.status).to eq(408)
      expect(notification.agent_id).to eq(subject.id)
    end
  end

  context "parse_data" do

    let(:work) { FactoryGirl.create(:work, :canonical_url => "http://www.plosmedicine.org/article/info:doi/10.1371/journal.pmed.0020124") }

    it "should report if the doi and canonical URL are missing" do
      work = FactoryGirl.create(:work, doi: nil, canonical_url: nil)
      result = {}
      result.extend Hashie::Extensions::DeepFetch
      expect(subject.parse_data(result, work_id: work.id)).to eq([])
    end

    it "should report if there are no events returned by the Facebook API" do
      body = File.read(fixture_path + 'facebook_nil.json')
      result = JSON.parse(body)
      result.extend Hashie::Extensions::DeepFetch
      response = subject.parse_data(result, work_id: work.id)

      expect(response).to eq([])
    end

    it "should report if there are events returned by the Facebook API" do
      body = File.read(fixture_path + 'facebook.json')
      result = JSON.parse(body)
      result.extend Hashie::Extensions::DeepFetch
      response = subject.parse_data(result, work_id: work.id)

      expect(response.length).to eq(1)
      expect(response.first[:relation]).to eq("subj_id"=>work.pid,
                                              "obj_id"=>"https://facebook.com/",
                                              "relation_type_id"=>"is_referenced_by",
                                              "total"=>9972,
                                              "source_id"=>"facebook")
    end

    it "should catch errors with the Facebook API" do
      result = { error: "the server responded with status 401 for https://graph.facebook.com/fql?access_token=EXAMPLE&q=select%20url,%20share_count,%20like_count,%20comment_count,%20click_count,%20total_count%20from%20link_stat%20where%20url%20=%20'http%253A%252F%252Fwww.plosmedicine.org%252Farticle%252Finfo%253Adoi%252F#{CGI.escape(work.doi_escaped)}'", status: 408 }
      response = subject.parse_data(result, work_id: work.id)
      expect(response).to eq(result)
    end
  end

  context "parse_data with url_linkstat" do
    subject { FactoryGirl.create(:facebook, url_linkstat: "https://graph.facebook.com/fql?access_token=%{access_token}&q=select url, share_count, like_count, comment_count, click_count, total_count from link_stat where url = '%{query_url}'") }
    let(:work) { FactoryGirl.create(:work, :canonical_url => "http://www.plosmedicine.org/work/info:doi/10.1371/journal.pmed.0020124") }

    it "should report if there are no events returned by the Facebook API" do
      body = File.read(fixture_path + 'facebook_linkstat_nil.json')
      result = JSON.parse(body)
      result.extend Hashie::Extensions::DeepFetch
      response = subject.parse_data(result, work_id: work.id)

      expect(response).to eq([])
    end

    it "should report if there are events returned by the Facebook API" do
      body = File.read(fixture_path + 'facebook_linkstat.json')
      result = JSON.parse(body)
      result.extend Hashie::Extensions::DeepFetch
      response = subject.parse_data(result, work_id: work.id)

      expect(response.length).to eq(3)
      expect(response[0][:relation]).to eq("subj_id"=>work.pid,
                                           "obj_id"=>"https://facebook.com/",
                                           "relation_type_id"=>"is_bookmarked_by",
                                           "total"=>3120,
                                           "source_id"=>"facebook")

      expect(response[1][:relation]).to eq("subj_id"=>work.pid,
                                           "obj_id"=>"https://facebook.com/",
                                           "relation_type_id"=>"is_discussed_by",
                                           "total"=>1910,
                                           "source_id"=>"facebook")
      expect(response[2][:relation]).to eq("subj_id"=>work.pid,
                                           "obj_id"=>"https://facebook.com/",
                                           "relation_type_id"=>"is_liked_by",
                                           "total"=>1715,
                                           "source_id"=>"facebook")

    end
  end
end
