require 'spec_helper'

describe CrossRef do
  let(:cross_ref) { FactoryGirl.create(:cross_ref) }

  it "should report that there are no events if the doi is missing" do
    article_without_doi = FactoryGirl.build(:article, :doi => "")
    cross_ref.get_data(article_without_doi).should eq({ :events => [], :event_count => nil })
  end

  it "should report that there are no events if article was published on the same day" do
    article_without_doi = FactoryGirl.build(:article, :published_on => Time.zone.today)
    cross_ref.get_data(article_without_doi).should eq({ :events => [], :event_count => nil })
  end

  context "lookup original URL" do
    it "should look up original URL if there is no article url" do
      article = FactoryGirl.build(:article, :doi => "10.1371/journal.pone.0043007", :url => nil)
      lookup_stub = stub_request(:head, article.doi_as_url).to_return(:status => 404)
      response = cross_ref.get_data(article)
      lookup_stub.should have_been_requested
    end

    it "should not look up original URL if there is article url" do
      article = FactoryGirl.build(:article, :doi => "10.1371/journal.pone.0043007", :url => "http://www.plosone.org/article/info%3Adoi%2F10.1371%2Fjournal.pone.0043007")
      lookup_stub = stub_request(:head, article.url).to_return(:status => 200, :headers => { 'Location' => article.url })
      stub = stub_request(:get, cross_ref.get_query_url(article)).to_return(:body => File.read(fixture_path + 'cross_ref_nil.xml'), :status => 200)
      response = cross_ref.get_data(article)
      lookup_stub.should_not have_been_requested
      stub.should have_been_requested
    end
  end

  context "use the CrossRef API" do
    let(:article) { FactoryGirl.build(:article, :doi => "10.1371/journal.pone.0043007", :url => "http://www.plosone.org/article/info%3Adoi%2F10.1371%2Fjournal.pone.0043007") }

    it "should report if there are no events and event_count returned by the CrossRef API" do
      stub = stub_request(:get, cross_ref.get_query_url(article)).to_return(:body => File.read(fixture_path + 'cross_ref_nil.xml'), :status => 200)
      cross_ref.get_data(article).should eq({ :events => [], :event_count => 0, :event_metrics => { :pdf=>nil, :html=>nil, :shares=>nil, :groups=>nil, :comments=>nil, :likes=>nil, :citations=>0, :total=>0 }, :attachment => nil })
      stub.should have_been_requested
    end

    it "should report if there are events and event_count returned by the CrossRef API" do
      stub = stub_request(:get, cross_ref.get_query_url(article)).to_return(:body => File.read(fixture_path + 'cross_ref.xml'), :status => 200)
      response = cross_ref.get_data(article)
      response[:events].length.should eq(31)
      response[:event_count].should eq(31)
      response[:attachment][:data].should be_true
      event = response[:events].first
      event[:event_url].should eq("http://dx.doi.org/#{event[:event]["doi"]}")
      stub.should have_been_requested
    end

    it "should catch errors with the CrossRef API" do
      stub = stub_request(:get, cross_ref.get_query_url(article)).to_return(:status => [408])
      cross_ref.get_data(article, options = { :source_id => cross_ref.id }).should be_nil
      stub.should have_been_requested
      Alert.count.should == 1
      alert = Alert.first
      alert.class_name.should eq("Net::HTTPRequestTimeOut")
      alert.status.should == 408
      alert.source_id.should == cross_ref.id
    end
  end

  context "use the CrossRef OpenURL API" do
    let(:article) { FactoryGirl.build(:article, :doi => "10.1007/s00248-010-9734-2", :url => "http://link.springer.com/article/10.1007%2Fs00248-010-9734-2#page-1") }

    it "should report if there is an event_count of zero returned by the CrossRef OpenURL API" do
      stub = stub_request(:get, cross_ref.get_default_query_url(article)).to_return(:body => File.read(fixture_path + 'cross_ref_openurl_nil.xml'), :status => 200)
      cross_ref.get_data(article).should eq({ :events => [], :event_count => 0 })
      stub.should have_been_requested
    end

    it "should report if there is an event_count greater than zero returned by the CrossRef OpenURL API" do
      stub = stub_request(:get, cross_ref.get_default_query_url(article)).to_return(:body => File.read(fixture_path + 'cross_ref_openurl.xml'), :status => 200)
      response = cross_ref.get_data(article)
      response[:event_count].should eq(13)
      stub.should have_been_requested
    end

    it "should catch errors with the CrossRef OpenURL API" do
      stub = stub_request(:get, cross_ref.get_default_query_url(article)).to_return(:status => [408])
      cross_ref.get_data(article, options = { :source_id => cross_ref.id }).should be_nil
      stub.should have_been_requested
      Alert.count.should == 1
      alert = Alert.first
      alert.class_name.should eq("Net::HTTPRequestTimeOut")
      alert.status.should == 408
      alert.source_id.should == cross_ref.id
    end
  end
end
