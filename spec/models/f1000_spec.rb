require 'spec_helper'

describe F1000 do
  subject { FactoryGirl.create(:f1000) }

  it "should report that there are no events if the doi is missing" do
    article = FactoryGirl.build(:article, :doi => "")
    subject.get_data(article).should eq(events: [], event_count: nil)
  end

  context "use the F1000 feed" do
    before(:each) do
      filename = "#{Rails.root}/data/#{subject.filename}"
      FileUtils.copy (fixture_path + 'f1000.xml'), filename unless File.exist?(filename)
    end

    it "should report if there are no events and event_count returned by the F1000 feed" do
      article = FactoryGirl.build(:article, :doi => "10.1371/journal.pone.0043007")
      subject.get_data(article).should eq(events: [], event_count: 0)
    end

    it "should report if there are events and event_count returned by the F1000 feed" do
      article = FactoryGirl.build(:article, :doi => "10.1371/journal.pgen.0020051")
      response = subject.get_data(article)
      response[:event_count].should eq(2)
      response[:events_url].should eq("http://f1000.com/prime/13421")
      response[:events]["Classifications"].should eq("NEW_FINDING")
      response[:attachment][:data].should be_true
    end

    it "should fetch the F1000 feed if the file is missing" do
      filename = "#{Rails.root}/data/#{subject.filename}"
      body = File.open(filename, 'r') { |f| f.read }
      File.delete filename
      stub = stub_request(:get, "http://example.org/example.xml").to_return(:status => 200, :body => body)

      article = FactoryGirl.build(:article, :doi => "10.1371/journal.pgen.0020051")
      response = subject.get_data(article)
      response[:event_count].should eq(2)
      response[:events_url].should eq("http://f1000.com/prime/13421")
      response[:events]["Classifications"].should eq("NEW_FINDING")
      response[:attachment][:data].should be_true
      stub.should have_been_requested
    end

    it "should catch an error when the F1000 feed can't be fetched" do
      filename = "#{Rails.root}/data/#{subject.filename}"
      File.delete filename
      stub = stub_request(:get, "http://example.org/example.xml").to_return(:status => [408])

      article = FactoryGirl.build(:article, :doi => "10.1371/journal.pone.0043007")
      subject.get_data(article).should be_nil
      stub.should have_been_requested
      Alert.count.should == 1
      alert = Alert.first
      alert.class_name.should eq("Net::HTTPRequestTimeOut")
      alert.status.should == 408
      alert.source_id.should == subject.id
    end

    it "should catch an error when the F1000 feed can't be saved" do
      filename = "#{Rails.root}/data/#{subject.filename}"
      body = File.open(filename, 'r') { |f| f.read }
      subject.filename = ""
      stub = stub_request(:get, "http://example.org/example.xml").to_return(:status => 200, :body => body)

      article = FactoryGirl.build(:article, :doi => "10.1371/journal.pgen.0020051")
      subject.get_data(article, options = { :source_id => subject.id }).should be_nil
      stub.should have_been_requested
      Alert.count.should == 1
      alert = Alert.first
      alert.class_name.should eq("Errno::EISDIR")
      alert.message.should include("Is a directory")
      alert.status.should == 500
      alert.source_id.should == subject.id
    end
  end
end
