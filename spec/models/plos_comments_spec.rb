require 'spec_helper'

describe PlosComments do
  subject { FactoryGirl.create(:plos_comments) }

  it "should report that there are no events if the doi is missing" do
    article = FactoryGirl.build(:article, :doi => "")
    subject.parse_data(article).should eq(events: [], event_count: nil)
  end

  it "should report that there are no events if the doi has the wrong prefix" do
    article = FactoryGirl.build(:article, :doi => "10.5194/acp-12-12021-2012")
    subject.parse_data(article).should eq(events: [], event_count: nil)
  end

  context "use the PLOS comments API" do
    it "should report if the article was not found by the PLOS comments API" do
      article = FactoryGirl.build(:article, :doi => "10.1371/journal.pone.0067729")
      stub = stub_request(:get, subject.get_query_url(article)).to_return(:headers => { "Content-Type" => "application/json" }, :body => File.read(fixture_path + 'plos_comments_error.txt'), :status => 404)
      subject.parse_data(article).should eq(events: [], event_count: nil)
      stub.should have_been_requested
    end

    it "should report if there are no events and event_count returned by the PLOS comments API" do
      article = FactoryGirl.build(:article, :doi => "10.1371/journal.pone.0067729")
      stub = stub_request(:get, subject.get_query_url(article)).to_return(:headers => { "Content-Type" => "application/json" }, :body => File.read(fixture_path + 'plos_comments_nil.json'), :status => 200)
      subject.parse_data(article).should eq(events: [], event_count: nil)
      stub.should have_been_requested
    end

    it "should report if there are events and event_count returned by the PLOS comments API" do
      article = FactoryGirl.build(:article, :doi => "10.1371/journal.pmed.0020124")
      stub = stub_request(:get, subject.get_query_url(article)).to_return(:headers => { "Content-Type" => "application/json" }, :body => File.read(fixture_path + 'plos_comments.json'), :status => 200)
      response = subject.parse_data(article)
      response[:event_count].should == 36
      response[:event_metrics].should eq(pdf: nil, html: nil, shares: nil, groups: nil, comments: 31, likes: nil, citations: nil, total: 36)
      stub.should have_been_requested
      event = response[:events].last
      event["originalTitle"].should eq("A small group research.")
      event["totalNumReplies"].should == 0
      stub.should have_been_requested
    end

    it "should catch timeout errors with the PLOS comments API" do
      article = FactoryGirl.build(:article, :doi => "10.1371/journal.pone.0067729")
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
