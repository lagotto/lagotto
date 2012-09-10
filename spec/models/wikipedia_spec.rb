require 'spec_helper'

describe Wikipedia do
  
  before(:each) do
    @wikipedia = FactoryGirl.create(:wikipedia)
  end
  
  it "should report that there are no events if the doi is missing" do
    article_without_doi = FactoryGirl.build(:article, :doi => "")
    @wikipedia.get_data(article_without_doi).should eq({ :events => [], :event_count => 0 })
  end
  
  context "use the CrossRef API" do
    it "should catch errors with the Wikipedia API" do
      @article = FactoryGirl.build(:article, :doi => "10.1371/journal.pone.0000001")
      stub = stub_request(:get, @wikipedia.get_query_url(@article)).to_return(:status => 408)
      lambda { @wikipedia.get_data(@article) }.should raise_error(Net::HTTPServerException)
      stub.should have_been_requested
    end
  end
end