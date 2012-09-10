require 'spec_helper'

describe Citeulike do
  
  before(:each) do
    @citeulike = FactoryGirl.create(:citeulike)
    @article = FactoryGirl.build(:article, :doi => "10.1371/journal.pone.0000001")
  end
  
  it "should catch errors with the CiteULike API" do
    stub = stub_request(:get, @citeulike.get_query_url(@article)).to_return(:status => 408)
    lambda { @citeulike.get_data(@article) }.should raise_error(Net::HTTPServerException)
    stub.should have_been_requested
  end

end