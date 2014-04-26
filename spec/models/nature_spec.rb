require 'spec_helper'

describe Nature do
  subject { FactoryGirl.create(:nature) }

  it "should report that there are no events if the doi is missing" do
    article_without_doi = FactoryGirl.build(:article, :doi => "")
    subject.parse_data(article_without_doi).should eq(events: [], event_count: nil)
  end

  context "use the Nature Blogs API" do
    it "should report if there are no events and event_count returned by the Nature Blogs API" do
      article_without_events = FactoryGirl.build(:article, :doi => "10.1371/journal.pone.0044294")
      stub = stub_request(:get, subject.get_query_url(article_without_events)).to_return(:headers => { "Content-Type" => "application/json" }, :body => File.read(fixture_path + 'nature_nil.json'), :status => 200)
      subject.parse_data(article_without_events).should eq(events: [], event_count: 0, event_metrics: { pdf: nil, html: nil, shares: nil, groups: nil, comments: nil, likes: nil, citations: 0, total: 0 })
      stub.should have_been_requested
    end

    it "should report if there are events and event_count returned by the Nature Blogs API" do
      article = FactoryGirl.build(:article, :doi => "10.1371/journal.pone.0008776")
      stub = stub_request(:get, subject.get_query_url(article)).to_return(:headers => { "Content-Type" => "application/json" }, :body => File.read(fixture_path + 'nature.json'), :status => 200)
      response = subject.parse_data(article)
      response[:event_count].should eq(10)
      stub.should have_been_requested
    end

    it "should catch errors with the Nature Blogs API" do
      article = FactoryGirl.build(:article, :doi => "10.1371/journal.pone.0000001")
      stub = stub_request(:get, subject.get_query_url(article)).to_return(:status => [408])
      subject.parse_data(article, options = { :source_id => subject.id }).should be_nil
      stub.should have_been_requested
      Alert.count.should == 1
      alert = Alert.first
      alert.class_name.should eq("Net::HTTPRequestTimeOut")
      alert.status.should == 408
      alert.source_id.should == subject.id
    end
  end
end
