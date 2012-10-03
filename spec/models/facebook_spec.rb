require 'spec_helper'

describe Facebook do
  before(:each) do
    @facebook = FactoryGirl.create(:facebook)
  end
  
  it "should report that there are no events if the doi and url are missing" do
    article_without_doi = FactoryGirl.build(:article, :doi => "", :url => "")
    @facebook.get_data(article_without_doi).should eq({ :events => [], :event_count => 0 })
  end
  
  it "should get the original url from the doi" do
    article_without_url = FactoryGirl.build(:article, :doi => "10.1371/journal.pone.0000001", :url => "")
    stub_original_url_lookup = stub_request(:get, article_without_url.doi_as_url)
    @facebook.update_original_url(article_without_url)
  end
  
  context "use the Facebook API" do
    before(:each) do
      @article = FactoryGirl.build(:article, :doi => "10.1371/journal.pone.0000001")
      stub_original_url_lookup = stub_request(:get, @article.doi_as_url)
    end
    
    it "should catch errors with the Facebook API" do
      graph_url = "https://graph.facebook.com/fql?access_token=#{@facebook.api_key}&q=select%20url,%20normalized_url,%20share_count,%20like_count,%20comment_count,%20total_count,%20click_count,%20comments_fbid,%20commentsbox_count%20from%20link_stat%20where%20url%20=%20"
      stub = stub_request(:get, graph_url + "'#{@article.doi_as_url}'").to_return(:status => 408)
      publisher_stub = stub_request(:get, graph_url + "'#{@article.doi_as_publisher_url}'").to_return(:status => 408)
      #lambda { @facebook.get_data(@article) }.should raise_error(Net::HTTPServerException)
      #stub.should have_been_requested
    end
  end
end