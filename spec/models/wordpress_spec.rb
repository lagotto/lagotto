# encoding: UTF-8

require 'spec_helper'

describe Wordpress do
  let(:wordpress) { FactoryGirl.create(:wordpress) }

  it "should report that there are no events if the doi is missing" do
    article = FactoryGirl.build(:article, :doi => "")
    wordpress.get_data(article).should eq({ :events => [], :event_count => nil })
  end

  context "use the Wordpress API" do
    it "should report if there are no events and event_count returned by the Wordpress API" do
      article = FactoryGirl.build(:article, :doi => "10.1371/journal.pone.0044294")
      stub = stub_request(:get, wordpress.get_query_url(article)).to_return(:headers => { "Content-Type" => "application/json" }, :body => File.read(fixture_path + 'wordpress_nil.json', encoding: 'UTF-8'), :status => 200)
      wordpress.get_data(article).should be_nil
      stub.should have_been_requested
    end

    it "should report if there are events and event_count returned by the Wordpress API" do
      article = FactoryGirl.build(:article, :doi => "10.1371/journal.pone.0008776")
      stub = stub_request(:get, wordpress.get_query_url(article)).to_return(:headers => { "Content-Type" => "application/json" }, :body => File.read(fixture_path + 'wordpress.json', encoding: 'UTF-8'), :status => 200)
      wordpress.get_data(article).should eq({ :event_count => 23, :events_url=>"http://en.search.wordpress.com/?q=\"#{article.doi}\"&t=post", :event_metrics => {:pdf=>nil, :html=>nil, :shares=>nil, :groups=>nil, :comments=>nil, :likes=>nil, :citations=>23, :total=>23} })
      stub.should have_been_requested
    end

    it "should catch errors with the Wordpress API" do
      article = FactoryGirl.build(:article, :doi => "10.1371/journal.pone.0000001")
      stub = stub_request(:get, wordpress.get_query_url(article)).to_return(:status => [408])
      wordpress.get_data(article, options = { :source_id => wordpress.id }).should be_nil
      stub.should have_been_requested
      Alert.count.should == 1
      alert = Alert.first
      alert.class_name.should eq("Net::HTTPRequestTimeOut")
      alert.status.should == 408
      alert.source_id.should == wordpress.id
    end
  end
end
