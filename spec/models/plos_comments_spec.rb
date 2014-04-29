require 'spec_helper'

describe PlosComments do
  subject { FactoryGirl.create(:plos_comments) }

  let(:article) { FactoryGirl.build(:article, :doi => "10.1371/journal.pone.0067729") }

  context "use the PLOS comments API" do
    it "should report that there are no events if the doi is missing" do
      article = FactoryGirl.build(:article, :doi => "")
      subject.get_data(article).should eq(events: [], event_count: nil)
    end

    it "should report that there are no events if the doi has the wrong prefix" do
      article = FactoryGirl.build(:article, :doi => "10.5194/acp-12-12021-2012")
      subject.get_data(article).should eq(events: [], event_count: nil)
    end

    it "should report if the article was not found by the PLOS comments API" do
      body = File.read(fixture_path + 'plos_comments_error.txt')
      stub = stub_request(:get, subject.get_query_url(article)).to_return(:headers => { "Content-Type" => "application/json" }, :body => body, :status => 404)
      response = subject.get_data(article)
      response.should eq(body)
      stub.should have_been_requested
    end

    it "should report if there are no events and event_count returned by the PLOS comments API" do
      body = File.read(fixture_path + 'plos_comments_nil.json')
      stub = stub_request(:get, subject.get_query_url(article)).to_return(:headers => { "Content-Type" => "application/json" }, :body => body, :status => 200)
      response = subject.get_data(article)
      response.should eq (JSON.parse(body))
      stub.should have_been_requested
    end

    it "should report if there are events and event_count returned by the PLOS comments API" do
      article = FactoryGirl.build(:article, :doi => "10.1371/journal.pmed.0020124")
      body = File.read(fixture_path + 'plos_comments.json')
      stub = stub_request(:get, subject.get_query_url(article)).to_return(:headers => { "Content-Type" => "application/json" }, :body => body, :status => 200)
      response = subject.get_data(article)
      response.should eq (JSON.parse(body))
      stub.should have_been_requested
    end

    it "should catch timeout errors with the PLOS comments API" do
      stub = stub_request(:get, subject.get_query_url(article)).to_return(:status => [408])
      subject.get_data(article, options = { :source_id => subject.id }).should be_nil
      stub.should have_been_requested
      Alert.count.should == 1
      alert = Alert.first
      alert.class_name.should eq("Net::HTTPRequestTimeOut")
      alert.status.should == 408
      alert.source_id.should == subject.id
    end
  end

  context "parse_data" do
    it "should report if the article was not found by the PLOS comments API" do
      body = File.read(fixture_path + 'plos_comments_error.txt')
      response = subject.parse_data(body, article)
      response.should eq(events: [], event_count: nil)
    end

    it "should report if there are no events and event_count returned by the PLOS comments API" do
      body = File.read(fixture_path + 'plos_comments_nil.json')
      result = JSON.parse(body)
      response = subject.parse_data(result, article)
      response.should eq(events: [], event_count: nil)
    end

    it "should report if there are events and event_count returned by the PLOS comments API" do
      article = FactoryGirl.build(:article, :doi => "10.1371/journal.pmed.0020124")
      body = File.read(fixture_path + 'plos_comments.json')
      result = JSON.parse(body)
      response = subject.parse_data(result, article)
      response[:event_count].should == 36
      response[:event_metrics].should eq(pdf: nil, html: nil, shares: nil, groups: nil, comments: 31, likes: nil, citations: nil, total: 36)
      event = response[:events].last
      event["originalTitle"].should eq("A small group research.")
      event["totalNumReplies"].should == 0
    end
  end
end
