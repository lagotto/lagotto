require 'spec_helper'

describe PubMed do
  before(:each) do
    @pub_med = FactoryGirl.create(:pub_med)
  end
  
  it "should report that there are no events if the doi and pmid are missing" do
    article_without_doi = FactoryGirl.build(:article, :doi => "", :pub_med => "")
    @pub_med.get_data(article_without_doi).should eq({ :events => [], :event_count => 0 })
  end
  
  context "use the PubMed API" do
  
    context "use article without events" do
      it "should not retrieve the PMCID for articles less than one month old" do
        article_recently_published = FactoryGirl.build(:article, :doi => "10.1371/journal.pone.0008776", :pub_med_central => "", :published_on => (Date.today - 7).to_s(:db))
        stub_pmid_lookup = stub_request(:get, PubMed::EUTILS_URL).to_return(:body => File.read(fixture_path + 'pub_med_esearch_pmid_nil.xml'), :status => 200)    
        stub_pmcid_lookup = stub_request(:get, PubMed::EUTILS_URL + "db=pmc&field=DOI&term=#{article_recently_published.doi}&tool=ArticleLevelMetrics").to_return(:body => File.read(fixture_path + 'pub_med_esearch_pmcid_nil.xml'), :status => 200)
        stub = stub_request(:get, @pub_med.get_query_url(article_recently_published)).to_return(:body => File.read(fixture_path + 'pub_med_nil.xml'), :status => 200)
        
        @pub_med.get_data(article_recently_published).should eq({ :events => [], :event_count => 0 })
        stub.should have_been_requested
        stub_pmcid_lookup.should_not have_been_requested
      end
      
      it "should report if there are no events and event_count returned by the PubMed API" do
        article_without_events = FactoryGirl.build(:article, :doi => "10.1371/journal.pone.0008776")
        stub_pmid_lookup = stub_request(:get, PubMed::EUTILS_URL).to_return(:body => File.read(fixture_path + 'pub_med_esearch_pmid_nil.xml'), :status => 200)    
        stub_pmcid_lookup = stub_request(:get, PubMed::EUTILS_URL).to_return(:body => File.read(fixture_path + 'pub_med_esearch_pmcid_nil.xml'), :status => 200)
        stub = stub_request(:get, @pub_med.get_query_url(article_without_events)).to_return(:body => File.read(fixture_path + 'pub_med_nil.xml'), :status => 200)
        @pub_med.get_data(article_without_events).should eq({ :events => [], :event_count => 0 })
        stub.should have_been_requested
      end
    end
    
    context "use article with events" do
      before(:each) do
        @article = FactoryGirl.build(:article, :doi => "10.1371/journal.pone.0000001")
        stub_pmid_lookup = stub_request(:get, PubMed::EUTILS_URL).to_return(:body => File.read(fixture_path + 'pub_med_esearch_pmid.xml'), :status => 200)
        stub_pmcid_lookup = stub_request(:get, PubMed::EUTILS_URL).to_return(:body => File.read(fixture_path + 'pub_med_esearch_pmcid.xml'), :status => 200)
      end
  
      it "should report if there are events and event_count returned by the PubMed API" do
        stub_summary_lookup = stub_request(:get, PubMed::ESUMMARY_URL + "db=pmc&id=3292175,1976277,2464333,2576030,2724239,2763780,2782675,2824913,2886697,3051412,3098654,3098711,3292175&tool=ArticleLevelMetrics&version=2.0").to_return(:body => File.read(fixture_path + 'pub_med_esummary_pmcid.xml'), :status => 200)
        stub = stub_request(:get, @pub_med.get_query_url(@article)).to_return(:body => File.read(fixture_path + 'pub_med.xml'), :status => 200)
        response = @pub_med.get_data(@article)
        response[:events].length.should eq(13)
        response[:event_count].should eq(13)
        stub.should have_been_requested
      end
   
      it "should catch errors with the PubMed API" do
        stub = stub_request(:get, @pub_med.get_query_url(@article)).to_return(:status => 408)
        lambda { @pub_med.get_data(@article) }.should raise_error(Net::HTTPServerException)
        stub.should have_been_requested
      end
    end
  end
end
