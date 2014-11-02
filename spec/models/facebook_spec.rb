require 'spec_helper'

describe Facebook do
  subject { FactoryGirl.create(:facebook) }

  context "lookup access token" do
    it "should make the right API call" do
      subject.access_token = nil
      stub = stub_request(:get, subject.get_authentication_url).to_return(:body => File.read(fixture_path + 'facebook_auth.txt'))
      subject.get_access_token.should_not be false
      stub.should have_been_requested
      subject.access_token.should eq("778123482473896|xQ0RGAHG6k8VUZrliyHgIIkwZYM")
    end

    it "should look up access token if blank" do
      subject.access_token = nil
      article = FactoryGirl.create(:article, :doi => "10.1371/journal.pone.0043007", :canonical_url => "http://www.plosone.org/article/info%3Adoi%2F10.1371%2Fjournal.pone.0043007")
      stub_auth = stub_request(:get, subject.get_authentication_url).to_return(:body => File.read(fixture_path + 'facebook_auth.txt'))
      stub = stub_request(:get, subject.get_query_url(article)).to_return(:status => [408])

      response = subject.get_data(article, source_id: subject.id)
      response[:error].should_not be_nil
      stub_auth.should have_been_requested
      stub.should have_been_requested
    end
  end

  context "lookup canonical URL" do
    it "should look up canonical URL if there is no article url" do
      article = FactoryGirl.create(:article, :doi => "10.1371/journal.pone.0043007", :canonical_url => nil)
      report = FactoryGirl.create(:fatal_error_report_with_admin_user)
      lookup_stub = stub_request(:get, article.doi_as_url).to_return(:status => 404)
      response = subject.get_data(article)
      lookup_stub.should have_been_requested
    end

    it "should not look up canonical URL if there is article url" do
      article = FactoryGirl.create(:article, :doi => "10.1371/journal.pone.0043007", :canonical_url => "http://www.plosone.org/article/info%3Adoi%2F10.1371%2Fjournal.pone.0043007")
      lookup_stub = stub_request(:get, article.canonical_url).with(:headers => { 'Accept'=>'application/json', 'User-Agent'=>"Lagotto #{Rails.application.config.version} - http://#{ENV['SERVERNAME']}" })
          .to_return(:status => 200, :headers => { 'Location' => article.canonical_url })
      stub = stub_request(:get, subject.get_query_url(article)).to_return(:body => File.read(fixture_path + 'cross_ref_nil.xml'))
      response = subject.get_data(article)
      lookup_stub.should_not have_been_requested
      stub.should have_been_requested
    end
  end

  context "get_data" do
    it "should report that there are no events if the doi and canonical URL are missing" do
      article = FactoryGirl.build(:article, doi: nil, canonical_url: nil)
      subject.get_data(article).should eq({})
    end

    it "should report if there are no events and event_count returned by the Facebook API" do
      article = FactoryGirl.build(:article, :canonical_url => "http://www.plosone.org/article/info%3Adoi%2F10.1371%2Fjournal.pone.0000001")
      body = File.read(fixture_path + 'facebook_nil.json')
      stub = stub_request(:get, subject.get_query_url(article)).with(:headers => { 'Accept'=>'application/json', 'User-Agent'=>"Lagotto #{Rails.application.config.version} - http://#{ENV['SERVERNAME']}" })
        .to_return(:body => body)
      response = subject.get_data(article)
      response.should eq(JSON.parse(body))
      stub.should have_been_requested
    end

    it "should report if there are events and event_count returned by the Facebook API" do
      article = FactoryGirl.build(:article, :canonical_url => "http://www.plosmedicine.org/article/info:doi/10.1371/journal.pmed.0020124")
      body = File.read(fixture_path + 'facebook.json')
      stub = stub_request(:get, subject.get_query_url(article)).with(:headers => { 'Accept'=>'application/json', 'User-Agent'=>"Lagotto #{Rails.application.config.version} - http://#{ENV['SERVERNAME']}" })
        .to_return(:body => body)
      response = subject.get_data(article)
      response.should eq(JSON.parse(body))
      stub.should have_been_requested
    end

    it "should catch authorization errors with the Facebook API" do
      article = FactoryGirl.build(:article, :canonical_url => "http://www.plosmedicine.org/article/info:doi/10.1371/journal.pmed.0020124")
      stub = stub_request(:get, subject.get_query_url(article)).with(:headers => { 'Accept'=>'application/json', 'User-Agent'=>"Lagotto #{Rails.application.config.version} - http://#{ENV['SERVERNAME']}" })
        .to_return(:body => File.read(fixture_path + 'facebook_error.json'), :status => [401])
      response = subject.get_data(article, options = { :source_id => subject.id })
      response.should eq(error: "the server responded with status 401 for #{subject.get_query_url(article)}", status: 401)
      stub.should have_been_requested
      Alert.count.should == 1
      alert = Alert.first
      alert.class_name.should eq("Net::HTTPUnauthorized")
      alert.status.should == 401
      alert.source_id.should == subject.id
    end
  end

  context "get_data with linkstat_url" do
    subject { FactoryGirl.create(:facebook, linkstat_url: "https://graph.facebook.com/fql?access_token=%{access_token}&q=select url, share_count, like_count, comment_count, click_count, total_count from link_stat where url = '%{query_url}'") }

    it "should report if there are no events and event_count returned by the Facebook API" do
      article = FactoryGirl.build(:article, :canonical_url => "http://www.plosone.org/article/info%3Adoi%2F10.1371%2Fjournal.pone.0000001")
      body = File.read(fixture_path + 'facebook_linkstat_nil.json')
      stub = stub_request(:get, subject.get_query_url(article)).with(:headers => { 'Accept'=>'application/json', 'User-Agent'=>"Lagotto #{Rails.application.config.version} - http://#{ENV['SERVERNAME']}" })
        .to_return(:body => body)
      response = subject.get_data(article)
      response.should eq(JSON.parse(body))
      stub.should have_been_requested
    end

    it "should report if there are events and event_count returned by the Facebook API" do
      article = FactoryGirl.build(:article, :canonical_url => "http://www.plosmedicine.org/article/info:doi/10.1371/journal.pmed.0020124")
      body = File.read(fixture_path + 'facebook_linkstat.json')
      stub = stub_request(:get, subject.get_query_url(article)).with(:headers => { 'Accept'=>'application/json', 'User-Agent'=>"Lagotto #{Rails.application.config.version} - http://#{ENV['SERVERNAME']}" })
        .to_return(:body => body)
      response = subject.get_data(article)
      response.should eq(JSON.parse(body))
      stub.should have_been_requested
    end

    it "should catch authorization errors with the Facebook API" do
      article = FactoryGirl.build(:article, :canonical_url => "http://www.plosmedicine.org/article/info:doi/10.1371/journal.pmed.0020124")
      stub = stub_request(:get, subject.get_query_url(article)).with(:headers => { 'Accept'=>'application/json', 'User-Agent'=>"Lagotto #{Rails.application.config.version} - http://#{ENV['SERVERNAME']}" })
        .to_return(:body => File.read(fixture_path + 'facebook_error.json'), :status => [401])
      response = subject.get_data(article, options = { :source_id => subject.id })
      response.should eq(error: "the server responded with status 401 for #{subject.get_query_url(article)}", status: 401)
      stub.should have_been_requested
      Alert.count.should == 1
      alert = Alert.first
      alert.class_name.should eq("Net::HTTPUnauthorized")
      alert.status.should == 401
      alert.source_id.should == subject.id
    end

    it "should catch timeout errors with the Facebook API" do
      article = FactoryGirl.build(:article, :canonical_url => "http://www.plosmedicine.org/article/info:doi/10.1371/journal.pmed.0020124")
      stub = stub_request(:get, subject.get_query_url(article)).to_return(:status => [408])
      response = subject.get_data(article, options = { :source_id => subject.id })
      response.should eq(error: "the server responded with status 408 for #{subject.get_query_url(article)}", :status=>408)
      stub.should have_been_requested
      Alert.count.should == 1
      alert = Alert.first
      alert.class_name.should eq("Net::HTTPRequestTimeOut")
      alert.status.should == 408
      alert.source_id.should == subject.id
    end
  end

  context "parse_data" do

    let(:article) { FactoryGirl.build(:article, :canonical_url => "http://www.plosmedicine.org/article/info:doi/10.1371/journal.pmed.0020124") }

    it "should report if the doi and canonical URL are missing" do
      article = FactoryGirl.build(:article, doi: nil, canonical_url: nil)
      result = {}
      result.extend Hashie::Extensions::DeepFetch
      subject.parse_data(result, article).should eq(:events=>{}, :events_by_day=>[], :events_by_month=>[], :events_url=>nil, :event_count=>0, :event_metrics=>{:pdf=>nil, :html=>nil, :shares=>0, :groups=>nil, :comments=>0, :likes=>0, :citations=>nil, :total=>0})
    end

    it "should report if there are no events and event_count returned by the Facebook API" do
      body = File.read(fixture_path + 'facebook_nil.json')
      result = JSON.parse(body)
      result.extend Hashie::Extensions::DeepFetch
      response = subject.parse_data(result, article)
      response[:event_count].should == 0
      events = response[:events]
      events["og_object"].should eq("id"=>"318336314932679", "description"=>"PLOS ONE: an inclusive, peer-reviewed, open-access resource from the PUBLIC LIBRARY OF SCIENCE. Reports of well-performed scientific studies from all disciplines freely available to the whole world.", "title"=>"PLOS ONE: Neural Substrate of Cold-Seeking Behavior in Endotoxin Shock", "type"=>"website", "updated_time"=>"2013-01-11T22:07:49+0000", "url"=>"http://www.plosone.org/article/info%3Adoi%2F10.1371%2Fjournal.pone.0000001")
      events["share"].should eq("comment_count"=>0, "share_count"=>0)
    end

    it "should report if there are events and event_count returned by the Facebook API" do
      body = File.read(fixture_path + 'facebook.json')
      result = JSON.parse(body)
      result.extend Hashie::Extensions::DeepFetch
      response = subject.parse_data(result, article)
      response[:event_count].should == 9972
      events = response[:events]
      events["og_object"].should eq("id"=>"119940294870426", "description"=>"PLOS Medicine is an open-access, peer-reviewed medical journal that publishes outstanding human studies that substantially enhance the understanding of human health and disease.", "title"=>"Why Most Published Research Findings Are False", "type"=>"article", "updated_time"=>"2014-10-24T15:34:04+0000", "url"=>"http://www.plosmedicine.org/article/info%3Adoi%2F10.1371%2Fjournal.pmed.0020124")
      events["share"].should eq("comment_count"=>0, "share_count"=>9972)
    end

    it "should catch errors with the Facebook API" do
      result = { error: "the server responded with status 401 for https://graph.facebook.com/fql?access_token=EXAMPLE&q=select%20url,%20share_count,%20like_count,%20comment_count,%20click_count,%20total_count%20from%20link_stat%20where%20url%20=%20'http%253A%252F%252Fwww.plosmedicine.org%252Farticle%252Finfo%253Adoi%252F#{CGI.escape(article.doi_escaped)}'", status: 408 }
      response = subject.parse_data(result, article)
      response.should eq(result)
    end
  end

  context "parse_data with linkstat_url" do
    subject { FactoryGirl.create(:facebook, linkstat_url: "https://graph.facebook.com/fql?access_token=%{access_token}&q=select url, share_count, like_count, comment_count, click_count, total_count from link_stat where url = '%{query_url}'") }
    let(:article) { FactoryGirl.build(:article, :canonical_url => "http://www.plosmedicine.org/article/info:doi/10.1371/journal.pmed.0020124") }

    it "should report if there are no events and event_count returned by the Facebook API" do
      body = File.read(fixture_path + 'facebook_linkstat_nil.json')
      result = JSON.parse(body)
      result.extend Hashie::Extensions::DeepFetch
      response = subject.parse_data(result, article)
      response[:events].should eq([{"url"=>"http://dx.doi.org/10.1371/journal.pone.0000001", "share_count"=>0, "like_count"=>0, "comment_count"=>0, "click_count"=>0, "total_count"=>0, "comments_fbid"=>nil}, {"url"=>"http://www.plosmedicine.org/article/info:doi/10.1371/journal.pone.0000001", "share_count"=>0, "like_count"=>0, "comment_count"=>0, "click_count"=>0, "total_count"=>0, "comments_fbid"=>"10150168740355926"}])
      response[:event_count].should == 0
    end

    it "should report if there are events and event_count returned by the Facebook API" do
      body = File.read(fixture_path + 'facebook_linkstat.json')
      result = JSON.parse(body)
      result.extend Hashie::Extensions::DeepFetch
      response = subject.parse_data(result, article)
      response[:events].should eq([{"url"=>"http://dx.doi.org/10.1371/journal.pmed.0020124", "share_count"=>3120, "like_count"=>1715, "comment_count"=>1910, "click_count"=>2, "total_count"=>6745, "comments_fbid"=>"10150805897619922"}, {"url"=>"http://www.plosmedicine.org/article/info:doi/10.1371/journal.pmed.0020124", "share_count"=>3120, "like_count"=>1715, "comment_count"=>1910, "click_count"=>2, "total_count"=>6745, "comments_fbid"=>"10150168740355926"}])
      response[:event_count].should == 6745
    end
  end
end
