require 'spec_helper'

describe ScienceSeeker do
  
  before(:each) do
    @scienceseeker = FactoryGirl.create(:scienceseeker)
  end
  
  it "should report that there are no events if the doi is missing" do
    article_without_doi = FactoryGirl.build(:article, :doi => "")
    @scienceseeker.get_data(article_without_doi).should eq({ :events => [], :event_count => 0 })
  end
  
  context "use the ScienceSeeker API" do
    it "should report if there are no events and event_count returned by the ScienceSeeker API" do
      article_without_events = FactoryGirl.build(:article, :doi => "10.1371/journal.pmed.0020124")
      stub = stub_request(:get, @scienceseeker.get_query_url(article_without_events)).to_return(:body => File.read(fixture_path + 'science_seeker_nil.xml'), :status => 200)
      @scienceseeker.get_data(article_without_events).should eq({ :events => [], :event_count => 0 })
      stub.should have_been_requested
    end
    
    it "should report if there are events and event_count returned by the ScienceSeeker API" do
      @article = FactoryGirl.build(:article, :doi => "10.1371/journal.pone.0035869")
      stub = stub_request(:get, @scienceseeker.get_query_url(@article)).to_return(:body => File.read(fixture_path + 'science_seeker.xml'), :status => 200)
      response = @scienceseeker.get_data(@article)
      response[:event_count].should eq(3)
      response[:events_url].should eq("http://scienceseeker.org/posts/?filter0=citation&modifier0=doi&value0=#{@article.doi}")
      stub.should have_been_requested
    end
    
    it "should catch errors with the ScienceSeeker API" do
      @article = FactoryGirl.build(:article, :doi => "10.1371/journal.pone.0000001")
      stub = stub_request(:get, @scienceseeker.get_query_url(@article)).to_return(:status => 408)
      lambda { @scienceseeker.get_data(@article) }.should raise_error(Net::HTTPServerException)
      stub.should have_been_requested
    end
  end
end