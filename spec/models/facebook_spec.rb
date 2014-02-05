require 'spec_helper'

describe Facebook do
  let(:facebook) { FactoryGirl.create(:facebook) }

  it "should report that there are no events if the doi is missing" do
    article_without_doi = FactoryGirl.build(:article, :doi => "")
    facebook.get_data(article_without_doi).should eq({ :events => [], :event_count => nil })
  end

  context "use the Facebook API" do
    it "should report if there are no events and event_count returned by the Facebook API" do
      article = FactoryGirl.build(:article, :url => "http://www.plosone.org/article/info%3Adoi%2F10.1371%2Fjournal.pone.0000001")
      stub = stub_request(:get, facebook.get_query_url(article)).to_return(:headers => { "Content-Type" => "application/json" }, :body => File.read(fixture_path + 'facebook_nil.json'), :status => 200)
      response = facebook.get_data(article)
      response[:events].should be_true
      response[:event_count].should eq(0)
      stub.should have_been_requested
    end

    it "should report if there are events and event_count returned by the Facebook API" do
      article = FactoryGirl.build(:article, :url => "http://www.plosmedicine.org/article/info:doi/10.1371/journal.pmed.0020124")
      stub = stub_request(:get, facebook.get_query_url(article)).to_return(:headers => { "Content-Type" => "application/json" }, :body => File.read(fixture_path + 'facebook.json'), :status => 200)
      response = facebook.get_data(article)
      response[:events].should be_true
      response[:event_count].should eq(6745)
      stub.should have_been_requested
    end

    it "should catch errors with the Facebook API" do
      article = FactoryGirl.build(:article, :url => "http://www.plosone.org/article/info%3Adoi%2F10.1371%2Fjournal.pone.0000001")
      stub = stub_request(:get, facebook.get_query_url(article)).to_return(:headers => { "Content-Type" => "application/json" }, :body => File.read(fixture_path + 'facebook_error.json'), :status => [401])
      facebook.get_data(article, options = { :source_id => facebook.id }).should be_nil
      stub.should have_been_requested
      Alert.count.should == 1
      alert = Alert.first
      alert.class_name.should eq("Net::HTTPUnauthorized")
      alert.status.should == 401
      alert.source_id.should == facebook.id
    end
  end
end
