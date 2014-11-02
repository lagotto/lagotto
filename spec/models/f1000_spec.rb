require 'spec_helper'

describe F1000 do
  subject { FactoryGirl.create(:f1000) }

  it "should report that there are no events if the doi is missing" do
    article = FactoryGirl.build(:article, :doi => nil)
    subject.get_data(article).should eq({})
  end

  context "save f1000 data" do
    it "should fetch and save f1000 data" do
      # stub = stub_request(:get, subject.get_feed_url).to_return(:headers => { "Content-Type" => "application/xml" }, :body => File.read(fixture_path + 'f1000.xml'), :status => 200)
      # subject.get_feed.should be true
      # file = "#{Rails.root}/data/#{subject.filename}.xml"
      # File.exist?(file).should be true
      # stub.should have_been_requested
      # Alert.count.should == 0
    end
  end

  context "parse f1000 data" do
    before(:each) do
      subject.put_lagotto_data(subject.db_url)
      body = File.read(fixture_path + 'f1000.xml')
      File.open("#{Rails.root}/data/#{subject.filename}", 'w') { |file| file.write(body) }
    end

    after(:each) do
      subject.delete_lagotto_data(subject.db_url)
    end

    it "should parse f1000 data" do
      subject.parse_feed.should_not be_blank
      Alert.count.should == 0
    end
  end

  context "get_data from the f1000 internal database" do
    before(:each) do
      subject.put_lagotto_data(subject.db_url)
    end

    after(:each) do
      subject.delete_lagotto_data(subject.db_url)
    end

    it "should report if there are no events and event_count returned by f1000" do
      article = FactoryGirl.create(:article, :doi => "10.1371/journal.pone.0044294")
      body = File.read(fixture_path + 'f1000_nil.json')
      stub = stub_request(:get, subject.get_query_url(article)).to_return(:body => body, :status => [404])
      response = subject.get_data(article)
      response.should eq(error: "not_found", status: 404)
      stub.should have_been_requested
    end

    it "should report if there are events and event_count returned by f1000" do
      article = FactoryGirl.create(:article, :doi => "10.1371/journal.pbio.1001420")
      body = File.read(fixture_path + 'f1000.json')
      stub = stub_request(:get, subject.get_query_url(article)).to_return(:body => body)
      response = subject.get_data(article)
      response.should eq(JSON.parse(body))
      stub.should have_been_requested
    end

    it "should catch timeout errors with f1000" do
      article = FactoryGirl.create(:article, :doi => "10.1371/journal.pone.0000001")
      stub = stub_request(:get, subject.get_query_url(article)).to_return(:status => [408])
      response = subject.get_data(article, options = { :source_id => subject.id })
      response.should eq(error: "the server responded with status 408 for http://127.0.0.1:5984/f1000_test/#{article.doi_escaped}", status: 408)
      stub.should have_been_requested
      Alert.count.should == 1
      alert = Alert.first
      alert.class_name.should eq("Net::HTTPRequestTimeOut")
      alert.status.should == 408
      alert.source_id.should == subject.id
    end
  end

  context "parse_data from the f1000 internal database" do
    it "should report if there are no events and event_count returned by f1000" do
      article = FactoryGirl.create(:article, :doi => "10.1371/journal.pone.0044294")
      result = { error: "not_found", status: 404 }
      response = subject.parse_data(result, article)
      response.should eq(:events=>[], :events_by_day=>[], :events_by_month=>[], :event_count=>0, :events_url=>nil, :event_metrics=>{:pdf=>nil, :html=>nil, :shares=>nil, :groups=>nil, :comments=>nil, :likes=>nil, :citations=>0, :total=>0})
    end

    it "should report if there are events and event_count returned by f1000" do
      article = FactoryGirl.create(:article, :doi => "10.1371/journal.pbio.1001420")
      body = File.read(fixture_path + 'f1000.json')
      result = JSON.parse(body)
      response = subject.parse_data(result, article)
      response[:event_count].should == 2
      response[:events_url].should eq("http://f1000.com/prime/718293874")

      response[:events_by_month].length.should eq(1)
      response[:events_by_month].first.should eq(month: 4, year: 2014, total: 2)
      response[:event_metrics].should eq(pdf: nil, html: nil, shares: nil, groups: nil, comments: nil, likes: nil, citations: 2, total: 2)

      event = response[:events].last
      event[:event]['classifications'].should eq(["confirmation", "good_for_teaching"])
    end

    it "should catch timeout errors with f1000" do
      article = FactoryGirl.create(:article, :doi => "10.1371/journal.pone.0000001")
      result = { error: "the server responded with status 408 for http://127.0.0.1:5984/f1000_test/", status: 408 }
      response = subject.parse_data(result, article)
      response.should eq(result)
    end
  end
end
