require 'spec_helper'

describe Twitter do
  let(:twitter) { FactoryGirl.create(:twitter) }

  it "should report that there are no events if the doi is missing" do
    article_without_doi = FactoryGirl.build(:article, :doi => "")
    twitter.get_data(article_without_doi).should eq({ :events => [], :event_count => nil })
  end

  # context "use the Twitter API" do
  #   it "should catch errors with the Twitter API" do
  #     article = FactoryGirl.build(:article, :url => "http://www.plosone.org/article/info%3Adoi%2F10.1371%2Fjournal.pone.0000001")
  #     stub = stub_request(:get, twitter.get_query_url(article)).to_return(:status => [408, "Request Timeout"])
  #     twitter.get_data(article).should be_nil
  #     stub.should have_been_requested
  #     Alert.count.should == 1
  #     alert = Alert.first
  #     alert.class_name.should eq("Net::HTTPRequestTimeOut")
  #     alert.message.should include("Request Timeout")
  #     alert.status.should == 408
  #     alert.source_id.should == twitter.id
  #   end

  # end
end
