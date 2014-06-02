require 'spec_helper'

describe Facebook do
  subject { FactoryGirl.create(:facebook) }

  let(:article) { FactoryGirl.build(:article, :canonical_url => "http://www.plosmedicine.org/article/info:doi/10.1371/journal.pmed.0020124") }

  context "lookup canonical URL" do
    it "should look up canonical URL if there is no article url" do
      article = FactoryGirl.create(:article, :doi => "10.1371/journal.pone.0043007", :canonical_url => nil)
      lookup_stub = stub_request(:get, article.doi_as_url).to_return(:status => 404)
      response = subject.get_data(article)
      lookup_stub.should have_been_requested
    end

    it "should not look up canonical URL if there is article url" do
      article = FactoryGirl.create(:article, :doi => "10.1371/journal.pone.0043007", :canonical_url => "http://www.plosone.org/article/info%3Adoi%2F10.1371%2Fjournal.pone.0043007")
      lookup_stub = stub_request(:get, article.canonical_url).to_return(:status => 200, :headers => { 'Location' => article.canonical_url })
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
      stub = stub_request(:get, subject.get_query_url(article)).to_return(:body => body)
      response = subject.get_data(article)
      response.should eq(JSON.parse(body))
      stub.should have_been_requested
    end

    it "should report if there are events and event_count returned by the Facebook API" do
      body = File.read(fixture_path + 'facebook.json')
      stub = stub_request(:get, subject.get_query_url(article)).to_return(:body => body)
      response = subject.get_data(article)
      response.should eq(JSON.parse(body))
      stub.should have_been_requested
    end

    it "should catch authorization errors with the Facebook API" do
      stub = stub_request(:get, subject.get_query_url(article)).to_return(:body => File.read(fixture_path + 'facebook_error.json'), :status => [401])
      response = subject.get_data(article, options = { :source_id => subject.id })
      response.should eq(error: "the server responded with status 401 for #{subject.get_query_url(article)}")
      stub.should have_been_requested
      Alert.count.should == 1
      alert = Alert.first
      alert.class_name.should eq("Net::HTTPUnauthorized")
      alert.status.should == 401
      alert.source_id.should == subject.id
    end
  end

  context "parse_data" do
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
      response[:events].should be_true
      response[:event_count].should eq(0)
    end

    it "should report if there are events and event_count returned by the Facebook API" do
      body = File.read(fixture_path + 'facebook.json')
      result = JSON.parse(body)
      result.extend Hashie::Extensions::DeepFetch
      response = subject.parse_data(result, article)
      response[:events].should be_true
      response[:event_count].should eq(6745)
    end

    it "should catch errors with the Facebook API" do
      result = { error: "the server responded with status 401 for https://graph.facebook.com/fql?access_token=EXAMPLE&q=select%20url,%20share_count,%20like_count,%20comment_count,%20click_count,%20total_count%20from%20link_stat%20where%20url%20=%20'http%253A%252F%252Fwww.plosmedicine.org%252Farticle%252Finfo%253Adoi%252F#{CGI.escape(article.doi_escaped)}'" }
      response = subject.parse_data(result, article)
      response.should eq(result)
    end
  end
end
