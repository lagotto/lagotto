require 'spec_helper'

describe Openedition do
  let(:openedition) { FactoryGirl.create(:openedition) }

  it "should report that there are no events if the doi is missing" do
    article = FactoryGirl.build(:article, :doi => "")
    openedition.get_data(article).should eq({ :events => [], :event_count => nil })
  end

  context "use the Openedition API" do
    it "should report if there are no events and event_count returned by the Openedition API" do
      article = FactoryGirl.build(:article, :doi => "10.1371/journal.pone.0000001")
      stub = stub_request(:get, openedition.get_query_url(article)).to_return(:headers => { "Content-Type" => "application/xml" }, :body => File.read(fixture_path + 'openedition_nil.xml'), :status => 200)
      openedition.get_data(article).should eq({:events=>[], :events_url=>"http://search.openedition.org/index.php?op%5B%5D=AND&q%5B%5D=#{article.doi_escaped}&field%5B%5D=All&pf=Hypotheses.org", :event_count=>0, :event_metrics=>{:pdf=>nil, :html=>nil, :shares=>nil, :groups=>nil, :comments=>nil, :likes=>nil, :citations=>0, :total=>0}, :attachment=>nil})
      stub.should have_been_requested
    end

    it "should report if there are events and event_count returned by the Openedition API" do
      article = FactoryGirl.build(:article, :doi => "10.2307/683422")
      stub = stub_request(:get, openedition.get_query_url(article)).to_return(:headers => { "Content-Type" => "application/xml" }, :body => File.read(fixture_path + 'openedition.xml'), :status => 200)
      response = openedition.get_data(article)
      response[:event_count].should eq(1)
      response[:events_url].should eq("http://search.openedition.org/index.php?op%5B%5D=AND&q%5B%5D=#{article.doi_escaped}&field%5B%5D=All&pf=Hypotheses.org")
      event = response[:events].first
      event[:event_url].should_not be_nil
      event[:event_url].should eq(event[:event]['link'])
      stub.should have_been_requested
    end

    it "should catch errors with the Openedition API" do
      article = FactoryGirl.build(:article, :doi => "10.2307/683422")
      stub = stub_request(:get, openedition.get_query_url(article)).to_return(:status => [408])
      openedition.get_data(article, options = { :source_id => openedition.id }).should be_nil
      stub.should have_been_requested
      Alert.count.should == 1
      alert = Alert.first
      alert.class_name.should eq("Net::HTTPRequestTimeOut")
      alert.status.should == 408
      alert.source_id.should == openedition.id
    end
  end
end
