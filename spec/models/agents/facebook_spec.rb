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
      expect(subject.get_access_token).not_to be false
      expect(subject.access_token).to be_present
    end

    it "should look up access token if blank" do
      subject.access_token = nil
      work = FactoryGirl.create(:work, :doi => "10.1371/journal.pone.0043007", :canonical_url => "http://www.plosone.org/article/info%3Adoi%2F10.1371%2Fjournal.pone.0043007")
      stub_auth = stub_request(:get, subject.get_authentication_url).to_return(:body => File.read(fixture_path + 'facebook_auth.txt'))
      stub = stub_request(:get, subject.get_query_url(work_id: work.id)).to_return(:status => [408])

      response = subject.get_data(work_id: work.id, source_id: subject.source_id)
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
      expect(lookup_stub).to have_been_requested.twice()
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
      response = subject.get_data(work_id: work.id)
      expect(response['og_object']).to eq("id"=>"318336314932679",
                                          "description"=>"PLOS ONE: an inclusive, peer-reviewed, open-access resource from the PUBLIC LIBRARY OF SCIENCE. Reports of well-performed scientific studies from all disciplines freely available to the whole world.",
                                          "title"=>"PLOS ONE: Neural Substrate of Cold-Seeking Behavior in Endotoxin Shock",
                                          "type"=>"website",
                                          "updated_time"=>"2013-01-11T22:07:49+0000",
                                          "url"=>"http://www.plosone.org/article/info%3Adoi%2F10.1371%2Fjournal.pone.0000001")
      expect(response['share']).to eq("comment_count"=>0, "share_count"=>0)
      expect(response['id']).to eq("http://www.plosone.org/article/info:doi/10.1371/journal.pone.0000001")

    end

    it "should report if there are events returned by the Facebook API" do
      work = FactoryGirl.create(:work, :canonical_url => "http://www.plosmedicine.org/article/info:doi/10.1371/journal.pmed.0020124")
      response = subject.get_data(work_id: work.id)
      expect(response['og_object']).to eq("id"=>"947360915280805",
                                          "description"=>"Published research findings are sometimes refuted by subsequent evidence, says Ioannidis, with ensuing confusion and disappointment.",
                                          "title"=>"Why Most Published Research Findings Are False",
                                          "type"=>"article",
                                          "updated_time"=>"2016-04-03T10:55:53+0000",
                                          "url"=>"http://journals.plos.org/plosmedicine/article?id=10.1371%2Fjournal.pmed.0020124")
      expect(response['share']).to eq("comment_count"=>0, "share_count"=>5301)
      expect(response['id']).to eq("http://www.plosmedicine.org/article/info:doi/10.1371/journal.pmed.0020124")
    end

    it "should catch authorization errors with the Facebook API" do
      work = FactoryGirl.create(:work, :canonical_url => "http://www.plosmedicine.org/article/info:doi/10.1371/journal.pmed.0020124")
      stub = stub_request(:get, subject.get_query_url(work_id: work.id))
             .with(:headers => headers)
             .to_return(:body => File.read(fixture_path + 'facebook_error.json'), :status => [401])
      response = subject.get_data(work_id: work.id, source_id: subject.source_id)
      expect(response).to eq(error: "the server responded with status 401 for #{subject.get_query_url(work_id: work.id)}", status: 401)
      expect(stub).to have_been_requested
      expect(Notification.count).to eq(1)
      notification = Notification.first
      expect(notification.class_name).to eq("Net::HTTPUnauthorized")
      expect(notification.status).to eq(401)
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
      response = subject.get_data(work_id: work.id, source_id: subject.source_id)
      expect(response).to eq(error: "the server responded with status 401 for #{subject.get_query_url(work_id: work.id)}", status: 401)
      expect(stub).to have_been_requested
      expect(Notification.count).to eq(1)
      notification = Notification.first
      expect(notification.class_name).to eq("Net::HTTPUnauthorized")
      expect(notification.status).to eq(401)
    end

    it "should catch timeout errors with the Facebook API" do
      work = FactoryGirl.create(:work, :canonical_url => "http://www.plosmedicine.org/article/info:doi/10.1371/journal.pmed.0020124")
      stub = stub_request(:get, subject.get_query_url(work_id: work.id)).to_return(:status => [408])
      response = subject.get_data(work_id: work.id, source_id: subject.source_id)
      expect(response).to eq(error: "the server responded with status 408 for #{subject.get_query_url(work_id: work.id)}", :status=>408)
      expect(stub).to have_been_requested
      expect(Notification.count).to eq(1)
      notification = Notification.first
      expect(notification.class_name).to eq("Net::HTTPRequestTimeOut")
      expect(notification.status).to eq(408)
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
      allow(Time.zone).to receive(:now).and_return(Time.mktime(2013, 9, 5))
      body = File.read(fixture_path + 'facebook.json')
      result = JSON.parse(body)
      result.extend Hashie::Extensions::DeepFetch
      response = subject.parse_data(result, work_id: work.id)

      expect(response.length).to eq(1)
      expect(response.first[:occurred_at]).to eq("2013-09-01")
      expect(response.first[:relation]).to eq("subj_id"=>"https://facebook.com/2013/9",
                                              "obj_id"=>work.pid,
                                              "relation_type_id"=>"references",
                                              "total"=>9972,
                                              "source_id"=>"facebook")
      expect(response.first[:subj]).to eq("pid"=>"https://facebook.com/2013/9",
                                          "URL"=>"https://facebook.com",
                                          "title"=>"Facebook activity for September 2013",
                                          "type"=>"webpage",
                                          "issued"=>"2013-09-01")
    end

    it "should catch errors with the Facebook API" do
      result = { error: "the server responded with status 401 for https://graph.facebook.com/fql?access_token=EXAMPLE&q=select%20url,%20share_count,%20like_count,%20comment_count,%20click_count,%20total_count%20from%20link_stat%20where%20url%20=%20'http%253A%252F%252Fwww.plosmedicine.org%252Farticle%252Finfo%253Adoi%252F#{CGI.escape(work.doi_escaped)}'", status: 408 }
      response = subject.parse_data(result, work_id: work.id)
      expect(response).to eq([result])
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
      allow(Time.zone).to receive(:now).and_return(Time.mktime(2013, 9, 5))
      body = File.read(fixture_path + 'facebook_linkstat.json')
      result = JSON.parse(body)
      result.extend Hashie::Extensions::DeepFetch
      response = subject.parse_data(result, work_id: work.id)

      expect(response.length).to eq(3)
      expect(response[0][:occurred_at]).to eq("2013-09-01")
      expect(response[0][:relation]).to eq("subj_id"=>"https://facebook.com/2013/9",
                                           "obj_id"=>work.pid,
                                           "relation_type_id"=>"bookmarks",
                                           "total"=>3120,
                                           "source_id"=>"facebook")
      expect(response[0][:subj]).to eq("pid"=>"https://facebook.com/2013/9",
                                       "URL"=>"https://facebook.com",
                                       "title"=>"Facebook activity for September 2013",
                                       "type"=>"webpage",
                                       "issued"=>"2013-09-01")
      expect(response[1][:occurred_at]).to eq("2013-09-01")
      expect(response[1][:relation]).to eq("subj_id"=>"https://facebook.com/2013/9",
                                           "obj_id"=>work.pid,
                                           "relation_type_id"=>"discusses",
                                           "total"=>1910,
                                           "source_id"=>"facebook")
      expect(response[2][:occurred_at]).to eq("2013-09-01")
      expect(response[2][:relation]).to eq("subj_id"=>"https://facebook.com/2013/9",
                                           "obj_id"=>work.pid,
                                           "relation_type_id"=>"likes",
                                           "total"=>1715,
                                           "source_id"=>"facebook")

    end
  end
end
