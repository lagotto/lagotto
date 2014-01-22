require 'spec_helper'

describe PlosComments do
  let(:plos_comments) { FactoryGirl.create(:plos_comments) }

  it "should report that there are no events if the doi is missing" do
    article = FactoryGirl.build(:article, :doi => "")
    plos_comments.get_data(article).should eq({ :events => [], :event_count => nil })
  end

  it "should report that there are no events if the doi has the wrong prefix" do
    article = FactoryGirl.build(:article, :doi => "10.5194/acp-12-12021-2012")
    plos_comments.get_data(article).should eq({ :events => [], :event_count => nil })
  end

  context "use the PLOS comments API" do
    it "should report if there are no events and event_count returned by the PLOS comments API" do
      article = FactoryGirl.build(:article, :doi => "10.1371/journal.pone.0067729")
      stub = stub_request(:get, plos_comments.get_query_url(article)).to_return(:headers => { "Content-Type" => "application/json" }, :body => File.read(fixture_path + 'plos_comments_nil.json'), :status => 200)
      plos_comments.get_data(article).should eq({ :events => [], :event_count => nil })
      stub.should have_been_requested
    end

    it "should report if there are events and event_count returned by the PLOS comments API" do
      article = FactoryGirl.build(:article, :doi => "10.1371/journal.pmed.0020124")
      stub = stub_request(:get, plos_comments.get_query_url(article)).to_return(:headers => { "Content-Type" => "application/json" }, :body => File.read(fixture_path + 'plos_comments.json'), :status => 200)
      response = plos_comments.get_data(article)
      response[:event_count].should == 36
      response[:event_metrics].should eq({ :pdf=>nil, :html=>nil, :shares=>nil, :groups=>nil, :comments=>31, :likes=>nil, :citations=>nil, :total=>36 })
      stub.should have_been_requested
      event = response[:events].last
      event["originalTitle"].should eq("A small group research.")
      event["totalNumReplies"].should == 0
      stub.should have_been_requested
    end

    it "should catch timeout errors with the PLOS comments API" do
      article = FactoryGirl.build(:article, :doi => "10.1371/journal.pone.0067729")
      stub = stub_request(:get, plos_comments.get_query_url(article)).to_return(:status => [408])
      plos_comments.get_data(article, options = { :source_id => plos_comments.id }).should be_nil
      stub.should have_been_requested
      Alert.count.should == 1
      alert = Alert.first
      alert.class_name.should eq("Net::HTTPRequestTimeOut")
      alert.status.should == 408
      alert.source_id.should == plos_comments.id
    end
  end
end