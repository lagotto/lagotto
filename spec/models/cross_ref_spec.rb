require 'spec_helper'

describe CrossRef do
  subject { FactoryGirl.create(:cross_ref) }

  let(:article) { FactoryGirl.create(:article, :doi => "10.1371/journal.pone.0043007", :canonical_url => "http://www.plosone.org/article/info%3Adoi%2F10.1371%2Fjournal.pone.0043007") }

  it "should report that there are no events if the doi is missing" do
    article = FactoryGirl.build(:article, :doi => "")
    subject.get_data(article).should eq(events: [], event_count: nil)
  end

  it "should report that there are no events if article was published on the same day" do
    article = FactoryGirl.build(:article, :published_on => Time.zone.today)
    subject.get_data(article).should eq(events: [], event_count: nil)
  end

  context "get_data from the CrossRef API" do
    it "should report if there are no events and event_count returned by the CrossRef API" do
      body = File.read(fixture_path + 'cross_ref_nil.xml')
      stub = stub_request(:get, subject.get_query_url(article)).to_return(:body => body, :status => 200)
      response = subject.get_data(article)
      response.should eq(Hash.from_xml(body))
      stub.should have_been_requested
    end

    it "should report if there are events and event_count returned by the CrossRef API" do
      body = File.read(fixture_path + 'cross_ref.xml')
      stub = stub_request(:get, subject.get_query_url(article)).to_return(:body => body, :status => 200)
      response = subject.get_data(article)
      response.should eq(Hash.from_xml(body))
      stub.should have_been_requested
    end

    it "should catch errors with the CrossRef API" do
      stub = stub_request(:get, subject.get_query_url(article)).to_return(:status => [408])
      subject.get_data(article, source_id: subject.id).should be_nil
      stub.should have_been_requested
      Alert.count.should == 1
      alert = Alert.first
      alert.class_name.should eq("Net::HTTPRequestTimeOut")
      alert.status.should == 408
      alert.source_id.should == subject.id
    end
  end

  context "use the CrossRef OpenURL API" do
    let(:article) { FactoryGirl.create(:article, :doi => "10.1007/s00248-010-9734-2", :canonical_url => "http://link.springer.com/article/10.1007%2Fs00248-010-9734-2#page-1") }

    it "should report if there is an event_count of zero returned by the CrossRef OpenURL API" do
      body = File.read(fixture_path + 'cross_ref_openurl_nil.xml')
      stub = stub_request(:get, subject.get_query_url(article)).to_return(:body => body, :status => 200)
      response = subject.get_data(article)
      response.should eq(Hash.from_xml(body))
      stub.should have_been_requested
    end

    it "should report if there is an event_count greater than zero returned by the CrossRef OpenURL API" do
      body = File.read(fixture_path + 'cross_ref_openurl.xml')
      stub = stub_request(:get, subject.get_query_url(article)).to_return(:body => body, :status => 200)
      response = subject.get_data(article)
      response.should eq(Hash.from_xml(body))
      stub.should have_been_requested
    end

    it "should catch errors with the CrossRef OpenURL API" do
      stub = stub_request(:get, subject.get_query_url(article)).to_return(:status => [408])
      subject.get_data(article, source_id: subject.id).should be_nil
      stub.should have_been_requested
      Alert.count.should == 1
      alert = Alert.first
      alert.class_name.should eq("Net::HTTPRequestTimeOut")
      alert.status.should == 408
      alert.source_id.should == subject.id
    end
  end

  context "parse_data from the CrossRef API" do
    it "should report if there are no events and event_count returned by the CrossRef API" do
      body = File.read(fixture_path + 'cross_ref_nil.xml')
      result = Hash.from_xml(body)
      response = subject.parse_data(result, article)
      response.should eq(:events=>[], :events_url=>nil, :event_count=>0, :event_metrics=>{:pdf=>nil, :html=>nil, :shares=>nil, :groups=>nil, :comments=>nil, :likes=>nil, :citations=>0, :total=>0})
    end

    it "should report if there are events and event_count returned by the CrossRef API" do
      body = File.read(fixture_path + 'cross_ref.xml')
      result = Hash.from_xml(body)
      response = subject.parse_data(result, article)
      response[:events].length.should eq(31)
      response[:event_count].should eq(31)
      event = response[:events].first
      event[:event_url].should eq("http://dx.doi.org/#{event[:event]['doi']}")
    end
  end

  context "parse_data from the CrossRef OpenURL API" do
    let(:article) { FactoryGirl.create(:article, :doi => "10.1007/s00248-010-9734-2", :canonical_url => "http://link.springer.com/article/10.1007%2Fs00248-010-9734-2#page-1") }

    it "should report if there is an event_count of zero returned by the CrossRef OpenURL API" do
      body = File.read(fixture_path + 'cross_ref_openurl_nil.xml')
      result = Hash.from_xml(body)
      result.extend Hashie::Extensions::DeepFetch
      response = subject.parse_data(result, article)
      response.should eq(:events=>[], :events_url=>nil, :event_count=>0, :event_metrics=>{:pdf=>nil, :html=>nil, :shares=>nil, :groups=>nil, :comments=>nil, :likes=>nil, :citations=>0, :total=>0})
    end

    it "should report if there is an event_count greater than zero returned by the CrossRef OpenURL API" do
      body = File.read(fixture_path + 'cross_ref_openurl.xml')
      result = Hash.from_xml(body)
      result.extend Hashie::Extensions::DeepFetch
      response = subject.parse_data(result, article)
      response[:event_count].should eq(13)
    end
  end
end
