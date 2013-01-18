require 'spec_helper'

describe Facebook do
  let(:facebook) { FactoryGirl.create(:facebook) }
  
  it "should report that there are no events if the doi is missing" do
    article_without_doi = FactoryGirl.build(:article, :doi => "")
    facebook.get_data(article_without_doi).should eq({ :events => [], :event_count => 0 })
  end
  
  context "use the Facebook API" do    
    it "should report if there are no events and event_count returned by the Facebook API" do
      article = FactoryGirl.build(:article, :doi => "10.1371/journal.pone.0000001")
      stub = stub_request(:get, facebook.get_query_url(article)).to_return(:body => File.read(fixture_path + 'facebook_nil.json'), :status => 200)
      response = facebook.get_data(article)
      response[:events].should be_true
      response[:event_count].should eq(0)
      stub.should have_been_requested
    end
    
    it "should report if there are events and event_count returned by the Facebook API" do
      article = FactoryGirl.build(:article, :doi => "10.1371/journal.pmed.0020124")
      stub = stub_request(:get, facebook.get_query_url(article)).to_return(:body => File.read(fixture_path + 'facebook.json'), :status => 200)
      response = facebook.get_data(article)
      response[:events].should be_true
      response[:event_count].should eq(3127)
      stub.should have_been_requested
    end
    
    it "should report if there is an error returned by the Facebook API" do
      article = FactoryGirl.build(:article, :doi => "10.1371/journal.pmed.0020124")
      stub = stub_request(:get, facebook.get_query_url(article)).to_return(:body => File.read(fixture_path + 'facebook_error.json'), :status => 200)
      response = facebook.get_data(article)
      response.should eq({ :events => [], :event_count => 0 })
      stub.should have_been_requested
    end
    
    it "should catch errors with the Facebook API" do
      article = FactoryGirl.build(:article, :doi => "10.1371/journal.pone.0000001")
      stub = stub_request(:get, facebook.get_query_url(article)).to_return(:status => 408)
      lambda { facebook.get_data(article) }.should raise_error(Net::HTTPServerException, /408/)
      stub.should have_been_requested
    end

  end
end