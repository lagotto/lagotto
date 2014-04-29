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
      lookup_stub = stub_request(:get, article.canonical_url)
        .to_return(:status => 200, :headers => { 'Location' => article.canonical_url })
      stub = stub_request(:get, subject.get_query_url(article))
        .to_return(:body => File.read(fixture_path + 'cross_ref_nil.xml'), :status => 200)
      response = subject.get_data(article)
      lookup_stub.should_not have_been_requested
      stub.should have_been_requested
    end
  end

  context "get_data" do
    it "should report that there are no events if the doi is missing" do
      article = FactoryGirl.build(:article, :doi => "")
      subject.get_data(article).should eq(events: [], event_count: nil)
    end

    it "should report if there are no events and event_count returned by the Facebook API" do
      article = FactoryGirl.build(:article, :canonical_url => "http://www.plosone.org/article/info%3Adoi%2F10.1371%2Fjournal.pone.0000001")
      body = File.read(fixture_path + 'facebook_nil.json')
      stub = stub_request(:get, subject.get_query_url(article))
        .to_return(:headers => { "Content-Type" => "application/json" }, :body => body, :status => 200)
      response = subject.get_data(article)
      response.should eq(JSON.parse(body))
      stub.should have_been_requested
    end

    it "should report if there are events and event_count returned by the Facebook API" do
      body = File.read(fixture_path + 'facebook.json')
      stub = stub_request(:get, subject.get_query_url(article)).to_return(:headers => { "Content-Type" => "application/json" }, :body => body, :status => 200)
      response = subject.get_data(article)
      response.should eq(JSON.parse(body))
      stub.should have_been_requested
    end

    it "should catch errors with the Facebook API" do
      stub = stub_request(:get, subject.get_query_url(article)).to_return(:headers => { "Content-Type" => "application/json" }, :body => File.read(fixture_path + 'facebook_error.json'), :status => [401])
      subject.get_data(article, options = { :source_id => subject.id }).should be_nil
      stub.should have_been_requested
      Alert.count.should == 1
      alert = Alert.first
      alert.class_name.should eq("Net::HTTPUnauthorized")
      alert.status.should == 401
      alert.source_id.should == subject.id
    end
  end

  context "parse_data" do
    it "should report if there are no events and event_count returned by the Facebook API" do
      body = File.read(fixture_path + 'facebook_nil.json')
      result = JSON.parse(body)
      response = subject.parse_data(result, article)
      response[:events].should be_true
      response[:event_count].should eq(0)
    end

    it "should report if there are events and event_count returned by the Facebook API" do
      body = File.read(fixture_path + 'facebook.json')
      result = JSON.parse(body)
      response = subject.parse_data(result, article)
      response[:events].should be_true
      response[:event_count].should eq(6745)
    end
  end
end
