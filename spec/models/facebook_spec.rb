require 'rails_helper'

describe Facebook, type: :model, vcr: true do
  subject { FactoryGirl.create(:facebook) }
  let(:headers) do
    { 'Accept'=>'application/json',
      'User-Agent'=>"Lagotto #{Lagotto::VERSION} - http://#{ENV['SERVERNAME']}" }
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

  context "get_data with url_linkstat" do
    subject { FactoryGirl.create(:facebook, url_linkstat: "https://graph.facebook.com/fql?access_token=%{access_token}&q=select url, share_count, like_count, comment_count, click_count, total_count from link_stat where url = '%{query_url}'") }

    it "should report if there are no events returned by the Facebook API" do
      work = FactoryGirl.create(:work, :canonical_url => "http://www.plosone.org/article/info%3Adoi%2F10.1371%2Fjournal.pone.0000001")
      body = File.read(fixture_path + 'facebook_linkstat_nil.json')
      stub = stub_request(:get, subject.get_query_url(work))
             .with(:headers => headers).to_return(:body => body)
      response = subject.get_data(work)
      expect(response).to eq(JSON.parse(body))
      expect(stub).to have_been_requested
    end

    it "should report if there are events returned by the Facebook API" do
      work = FactoryGirl.create(:work, :canonical_url => "http://www.plosmedicine.org/article/info:doi/10.1371/journal.pmed.0020124")
      body = File.read(fixture_path + 'facebook_linkstat.json')
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

    it "should catch timeout errors with the Facebook API" do
      work = FactoryGirl.create(:work, :canonical_url => "http://www.plosmedicine.org/article/info:doi/10.1371/journal.pmed.0020124")
      stub = stub_request(:get, subject.get_query_url(work)).to_return(:status => [408])
      response = subject.get_data(work, options = { :source_id => subject.id })
      expect(response).to eq(error: "the server responded with status 408 for #{subject.get_query_url(work)}", :status=>408)
      expect(stub).to have_been_requested
      expect(Alert.count).to eq(1)
      alert = Alert.first
      expect(alert.class_name).to eq("Net::HTTPRequestTimeOut")
      expect(alert.status).to eq(408)
      expect(alert.source_id).to eq(subject.id)
    end
  end

  context "parse_data" do

    let(:work) { FactoryGirl.create(:work, :canonical_url => "http://www.plosmedicine.org/article/info:doi/10.1371/journal.pmed.0020124") }

    it "should report if the doi and canonical URL are missing" do
      work = FactoryGirl.create(:work, doi: nil, canonical_url: nil)
      result = {}
      result.extend Hashie::Extensions::DeepFetch
      expect(subject.parse_data(result, work)).to eq(events: { source: "facebook", work: work.pid, readers: 0, comments: 0, likes: 0, total: 0, extra: {} })
    end

    it "should report if there are no events returned by the Facebook API" do
      body = File.read(fixture_path + 'facebook_nil.json')
      result = JSON.parse(body)
      result.extend Hashie::Extensions::DeepFetch
      response = subject.parse_data(result, work)
      expect(response[:events][:total]).to eq(0)

      extra = response[:events][:extra]
      expect(extra["og_object"]).to eq("id"=>"318336314932679", "description"=>"PLOS ONE: an inclusive, peer-reviewed, open-access resource from the PUBLIC LIBRARY OF SCIENCE. Reports of well-performed scientific studies from all disciplines freely available to the whole world.", "title"=>"PLOS ONE: Neural Substrate of Cold-Seeking Behavior in Endotoxin Shock", "type"=>"website", "updated_time"=>"2013-01-11T22:07:49+0000", "url"=>"http://www.plosone.org/article/info%3Adoi%2F10.1371%2Fjournal.pone.0000001")
      expect(extra["share"]).to eq("comment_count"=>0, "share_count"=>0)
    end

    it "should report if there are events returned by the Facebook API" do
      body = File.read(fixture_path + 'facebook.json')
      result = JSON.parse(body)
      result.extend Hashie::Extensions::DeepFetch
      response = subject.parse_data(result, work)
      expect(response[:events][:total]).to eq(9972)
      extra = response[:events][:extra]
      expect(extra["og_object"]).to eq("id"=>"119940294870426", "description"=>"PLOS Medicine is an open-access, peer-reviewed medical journal that publishes outstanding human studies that substantially enhance the understanding of human health and disease.", "title"=>"Why Most Published Research Findings Are False", "type"=>"article", "updated_time"=>"2014-10-24T15:34:04+0000", "url"=>"http://www.plosmedicine.org/article/info%3Adoi%2F10.1371%2Fjournal.pmed.0020124")
      expect(extra["share"]).to eq("comment_count"=>0, "share_count"=>9972)
    end

    it "should catch errors with the Facebook API" do
      result = { error: "the server responded with status 401 for https://graph.facebook.com/fql?access_token=EXAMPLE&q=select%20url,%20share_count,%20like_count,%20comment_count,%20click_count,%20total_count%20from%20link_stat%20where%20url%20=%20'http%253A%252F%252Fwww.plosmedicine.org%252Farticle%252Finfo%253Adoi%252F#{CGI.escape(work.doi_escaped)}'", status: 408 }
      response = subject.parse_data(result, work)
      expect(response).to eq(result)
    end
  end

  context "parse_data with url_linkstat" do
    subject { FactoryGirl.create(:facebook, url_linkstat: "https://graph.facebook.com/fql?access_token=%{access_token}&q=select url, share_count, like_count, comment_count, click_count, total_count from link_stat where url = '%{query_url}'") }
    let(:work) { FactoryGirl.build(:work, :canonical_url => "http://www.plosmedicine.org/work/info:doi/10.1371/journal.pmed.0020124") }

    it "should report if there are no events returned by the Facebook API" do
      body = File.read(fixture_path + 'facebook_linkstat_nil.json')
      result = JSON.parse(body)
      result.extend Hashie::Extensions::DeepFetch
      response = subject.parse_data(result, work)
      expect(response[:events][:extra]).to eq([{"url"=>"http://dx.doi.org/10.1371/journal.pone.0000001", "share_count"=>0, "like_count"=>0, "comment_count"=>0, "click_count"=>0, "total_count"=>0, "comments_fbid"=>nil}, {"url"=>"http://www.plosmedicine.org/article/info:doi/10.1371/journal.pone.0000001", "share_count"=>0, "like_count"=>0, "comment_count"=>0, "click_count"=>0, "total_count"=>0, "comments_fbid"=>"10150168740355926"}])
      expect(response[:events][:total]).to eq(0)
      expect(response[:events][:readers]).to eq(0)
      expect(response[:events][:comments]).to eq(0)
      expect(response[:events][:likes]).to eq(0)
    end

    it "should report if there are events returned by the Facebook API" do
      body = File.read(fixture_path + 'facebook_linkstat.json')
      result = JSON.parse(body)
      result.extend Hashie::Extensions::DeepFetch
      response = subject.parse_data(result, work)
      expect(response[:events][:extra]).to eq([{"url"=>"http://dx.doi.org/10.1371/journal.pmed.0020124", "share_count"=>3120, "like_count"=>1715, "comment_count"=>1910, "click_count"=>2, "total_count"=>6745, "comments_fbid"=>"10150805897619922"}, {"url"=>"http://www.plosmedicine.org/article/info:doi/10.1371/journal.pmed.0020124", "share_count"=>3120, "like_count"=>1715, "comment_count"=>1910, "click_count"=>2, "total_count"=>6745, "comments_fbid"=>"10150168740355926"}])
      expect(response[:events][:total]).to eq(6745)
      expect(response[:events][:readers]).to eq(3120)
      expect(response[:events][:comments]).to eq(1910)
      expect(response[:events][:likes]).to eq(1715)
    end
  end
end
