require 'spec_helper'

describe Facebook do
  let(:facebook) { FactoryGirl.create(:facebook) }
  
  it "should report that there are no events if the doi is missing" do
    article_without_doi = FactoryGirl.build(:article, :doi => "")
    facebook.get_data(article_without_doi).should eq({ :events => [], :event_count => 0 })
  end
  
  it "should get the original url from the doi" do
     article_without_url = FactoryGirl.build(:article, :doi => "10.1371/journal.pone.0000001", :url => "")
     stub_original_url_lookup = stub_request(:get, article_without_url.doi_as_url).to_return(:status => 200, :body => "http://www.plosone.org/article/info%3Adoi%2F10.1371%2Fjournal.pone.0000001")
     facebook.get_original_url(article_without_url.doi_as_url).should be_true
     stub_original_url_lookup.should have_been_requested
   end
  
  context "use the Facebook API" do    
    it "should report if there are no events and event_count returned by the Facebook API" do
      article = FactoryGirl.build(:article, :url => "http://www.plosone.org/article/info%3Adoi%2F10.1371%2Fjournal.pone.0000001")
      stub = stub_request(:get, facebook.get_query_url(article.url)).to_return(:body => File.read(fixture_path + 'facebook_nil.json'), :status => 200)
      response = facebook.get_data(article)
      response[:events].should be_true
      response[:event_count].should eq(0)
      stub.should have_been_requested
    end
    
    it "should report if there are events and event_count returned by the Facebook API" do
      article = FactoryGirl.build(:article, :url => "http://www.plosmedicine.org/article/info:doi/10.1371/journal.pmed.0020124")
      stub = stub_request(:get, facebook.get_query_url(article.url)).to_return(:body => File.read(fixture_path + 'facebook.json'), :status => 200)
      response = facebook.get_data(article)
      response[:events].should be_true
      response[:event_count].should eq(3127)
      stub.should have_been_requested
    end
    
    it "should catch errors with the Facebook API" do
      article = FactoryGirl.build(:article, :url => "http://www.plosone.org/article/info%3Adoi%2F10.1371%2Fjournal.pone.0000001")
      stub = stub_request(:get, facebook.get_query_url(article.url)).to_return(:body => File.read(fixture_path + 'facebook_error.json'), :status => [401, "Unauthorized"])
      facebook.get_data(article).should eq({ :events => [], :event_count => nil })
      stub.should have_been_requested
      ErrorMessage.count.should == 1
      error_message = ErrorMessage.first
      error_message.class_name.should eq("Net::HTTPUnauthorized")
      error_message.message.should include("Unauthorized")
      error_message.status.should == 401
      error_message.source_id.should == facebook.id
    end

  end
end