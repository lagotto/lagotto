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
    let(:article) { FactoryGirl.build(:article, :doi => "10.1371/journal.pone.0000001") }
    let(:graph_url) { "https://graph.facebook.com/fql?access_token=EXAMPLE&q=select%20url,%20normalized_url,%20share_count,%20like_count,%20comment_count,%20total_count,%20click_count,%20comments_fbid,%20commentsbox_count%20from%20link_stat%20where%20url%20=%20'http://dx.plos.org/10.1371/journal.pone.0000001'" }
    let(:stub_original_url_lookup) { stub_request(:get, article.doi_as_url) }
    
    it "should report if there are no events and event_count returned by the Facebook API" do
      #stub = stub_request(:get, graph_url).to_return(:status => 200, :body => "", :headers => {})
      #facebook.get_data(article).should eq({ :events => [], :event_count => 0 })
      #stub.should have_been_requested
    end
    
    it "should report if there are events and event_count returned by the Facebook API" do
      #stub = stub_request(:get, graph_url).to_return(:status => 200, :body => "", :headers => {})
      #response = facebook.get_data(article)
      #response[:events].should be_true
      #response[:event_count].should eq(4)
      #stub.should have_been_requested
    end
    
    it "should catch errors with the Facebook API" do
      #stub = stub_request(:get, graph_url + "'#{article.doi_as_url}'").to_return(:status => 408)
      #publisher_stub = stub_request(:get, graph_url + "'#{article.doi_as_publisher_url}'").to_return(:status => 408)
      #lambda { facebook.get_data(article) }.should raise_error(Net::HTTPServerException, /408/) 
      #stub.should have_been_requested
    end
  end
end