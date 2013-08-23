require 'spec_helper'

describe Researchblogging do
  let(:researchblogging) { FactoryGirl.create(:researchblogging) }

  it "should report that there are no events if the doi is missing" do
    article_without_doi = FactoryGirl.build(:article, :doi => "")
    researchblogging.get_data(article_without_doi).should eq({ :events => [], :event_count => nil })
  end

  context "use the ResearchBlogging API" do
    it "should report if there are no events and event_count returned by the ResearchBlogging API" do
      article = FactoryGirl.build(:article, :doi => "10.1371/journal.pmed.0020124")
      stub = stub_request(:get, "http://#{researchblogging.username}:#{researchblogging.password}@researchbloggingconnect.com/blogposts?article=doi:#{Addressable::URI.encode(article.doi)}&count=100").to_return(:body => File.read(fixture_path + 'researchblogging_nil.xml'), :status => 200)
      researchblogging.get_data(article).should eq({ :events => [], :event_count => 0, :event_metrics => { :pdf=>nil, :html=>nil, :shares=>nil, :groups=>nil, :comments=>nil, :likes=>nil, :citations=>0, :total=>0 }, :attachment => nil, :events_url => researchblogging.get_events_url(article) })
      stub.should have_been_requested
    end

    it "should report if there are events and event_count returned by the ResearchBlogging API" do
      article = FactoryGirl.build(:article, :doi => "10.1371/journal.pone.0035869")
      body = File.read(fixture_path + 'researchblogging.xml')
      stub = stub_request(:get, "http://#{researchblogging.username}:#{researchblogging.password}@researchbloggingconnect.com/blogposts?article=doi:#{Addressable::URI.encode(article.doi)}&count=100").to_return(:body => body, :status => 200)
      response = researchblogging.get_data(article)
      response[:event_count].should eq(8)
      response[:events].length.should eq(8)
      response[:events_url].should eq(researchblogging.get_events_url(article))
      response[:attachment][:data].should_not be_empty
      event = response[:events].first
      event[:event_url].should eq(event[:event]["post_URL"])
      stub.should have_been_requested
    end

    it "should catch errors with the ResearchBlogging API" do
      article = FactoryGirl.build(:article, :doi => "10.1371/journal.pone.0000001")
      stub = stub_request(:get, "http://#{researchblogging.username}:#{researchblogging.password}@researchbloggingconnect.com/blogposts?article=doi:#{Addressable::URI.encode(article.doi)}&count=100").to_return(:status => [408])
      researchblogging.get_data(article, options = { :source_id => researchblogging.id }).should be_nil
      stub.should have_been_requested
      ErrorMessage.count.should == 1
      error_message = ErrorMessage.first
      error_message.class_name.should eq("Faraday::Error::ClientError")
      error_message.status.should == 408
      error_message.source_id.should == researchblogging.id
    end
  end
end
