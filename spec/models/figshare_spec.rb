require 'spec_helper'

describe Figshare do
  let(:figshare) { FactoryGirl.create(:figshare) }

  it "should report that there are no events if the doi is missing" do
    article = FactoryGirl.build(:article, :doi => "")
    figshare.get_data(article).should eq({ :events => [], :event_count => nil })
  end

  it "should report that there are no events if the doi has the wrong prefix" do
    article = FactoryGirl.build(:article, :doi => "10.5194/acp-12-12021-2012")
    figshare.get_data(article).should eq({ :events => [], :event_count => nil })
  end

  context "use the figshare API" do
    it "should report if there are no events and event_count returned by the figshare API" do
      article = FactoryGirl.build(:article, :doi => "10.1371/journal.pone.0067729")
      stub = stub_request(:get, figshare.get_query_url(article)).to_return(:headers => { "Content-Type" => "application/json" }, :body => File.read(fixture_path + 'figshare_nil.json'), :status => 200)
      figshare.get_data(article).should eq({ :events => [], :event_count => nil })
      stub.should have_been_requested
    end

    it "should report if there are events and event_count returned by the figshare API" do
      article = FactoryGirl.build(:article, :doi => "10.1371/journal.pone.0067729")
      stub = stub_request(:get, figshare.get_query_url(article)).to_return(:headers => { "Content-Type" => "application/json" }, :body => File.read(fixture_path + 'figshare.json'), :status => 200)
      response = figshare.get_data(article)
      response[:event_count].should == 14
      response[:event_metrics].should eq({ :pdf=>1, :html=>13, :shares=>nil, :groups=>nil, :comments=>nil, :likes=>0, :citations=>nil, :total=>14 })
      stub.should have_been_requested
      events = response[:events]
      events["items"].should_not be_nil
      stub.should have_been_requested
    end

    it "should catch timeout errors with the figshare API" do
      article = FactoryGirl.build(:article, :doi => "10.1371/journal.pone.0067729")
      stub = stub_request(:get, figshare.get_query_url(article)).to_return(:status => [408])
      figshare.get_data(article, options = { :source_id => figshare.id }).should be_nil
      stub.should have_been_requested
      Alert.count.should == 1
      alert = Alert.first
      alert.class_name.should eq("Net::HTTPRequestTimeOut")
      alert.status.should == 408
      alert.source_id.should == figshare.id
    end
  end
end
