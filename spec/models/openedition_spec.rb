require 'spec_helper'

describe Openedition do
  subject { FactoryGirl.create(:openedition) }

  context "get_data" do
    it "should report that there are no events if the doi is missing" do
      article = FactoryGirl.build(:article, :doi => "")
      subject.get_data(article).should eq(events: [], event_count: nil)
    end

    it "should report if there are no events and event_count returned by the Openedition API" do
      article = FactoryGirl.build(:article, :doi => "10.1371/journal.pone.0000001")
      body = File.read(fixture_path + 'openedition_nil.xml')
      stub = stub_request(:get, subject.get_query_url(article)).to_return(:headers => { "Content-Type" => "application/xml" }, :body => body, :status => 200)
      response = subject.get_data(article)
      response.should eq(Hash.from_xml(body))
      stub.should have_been_requested
    end

    it "should report if there are events and event_count returned by the Openedition API" do
      article = FactoryGirl.build(:article, :doi => "10.2307/683422")
      body = File.read(fixture_path + 'openedition.xml')
      stub = stub_request(:get, subject.get_query_url(article)).to_return(:headers => { "Content-Type" => "application/xml" }, :body => body, :status => 200)
      response = subject.get_data(article)
      response.should eq(Hash.from_xml(body))
      stub.should have_been_requested
    end

    it "should catch errors with the Openedition API" do
      article = FactoryGirl.build(:article, :doi => "10.2307/683422")
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
    it "should report if there are no events and event_count returned by the Openedition API" do
      article = FactoryGirl.build(:article, :doi => "10.1371/journal.pone.0000001")
      body = File.read(fixture_path + 'openedition_nil.xml')
      result = Hash.from_xml(body)
      response = subject.parse_data(result, article)
      response.should eq(events: [], events_url: "http://search.openedition.org/index.php?op[]=AND&q[]=#{article.doi_escaped}&field[]=All&pf=Hypotheses.org", event_count: 0, event_metrics: { pdf: nil, html: nil, shares: nil, groups: nil, comments: nil, likes: nil, citations: 0, total: 0})
    end

    it "should report if there are events and event_count returned by the Openedition API" do
      article = FactoryGirl.build(:article, :doi => "10.2307/683422")
      body = File.read(fixture_path + 'openedition.xml')
      result = Hash.from_xml(body)
      response = subject.parse_data(result, article)
      response[:event_count].should eq(1)
      response[:events_url].should eq("http://search.openedition.org/index.php?op[]=AND&q[]=#{article.doi_escaped}&field[]=All&pf=Hypotheses.org")
      event = response[:events].first
      event[:event_url].should_not be_nil
      event[:event_url].should eq(event[:event]['link'])
    end
  end
end
