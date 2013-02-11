require 'spec_helper'

describe PubMed do
  let(:pub_med) { FactoryGirl.create(:pub_med) }
  
  it "should report that there are no events if the doi and pmid are missing" do
    article_without_doi = FactoryGirl.build(:article, :doi => "", :pub_med => "")
    pub_med.get_data(article_without_doi).should eq({ :events => [], :event_count => nil })
  end
  
  context "use the PubMed API" do
    context "use article without events" do
      it "should not retrieve the PMCID for articles less than one month old" do
        article_recently_published = FactoryGirl.build(:article, :doi => "10.1371/journal.pone.0008776", :pub_med => "17183631", :pub_med_central => "", :published_on => (Date.today - 7).to_s(:db))
        stub_pmid_lookup = stub_request(:get, PubMed::EUTILS_URL + "term=#{article_recently_published.doi}&field=DOI&db=pubmed&tool=#{PubMed::ToolID}").to_return(:body => File.read(fixture_path + 'pub_med_esearch_pmid_nil.xml'), :status => 200)
        stub_pmcid_lookup = stub_request(:get, PubMed::EUTILS_URL + "term=#{article_recently_published.doi}&field=DOI&db=pmc&tool=#{PubMed::ToolID}").to_return(:body => File.read(fixture_path + 'pub_med_esearch_pmcid_nil.xml'), :status => 200)
        stub = stub_request(:get, pub_med.get_query_url(article_recently_published)).to_return(:body => File.read(fixture_path + 'pub_med_nil.xml'), :status => 200)
        pub_med.get_data(article_recently_published).should eq({ :events => [], :event_count => 0, :events_url=>"http://www.ncbi.nlm.nih.gov/sites/entrez?db=pubmed&cmd=link&LinkName=pubmed_pmc_refs&from_uid=17183631", :event_metrics=>{:pdf=>nil, :html=>nil, :shares=>nil, :groups=>nil, :comments=>nil, :likes=>nil, :citations=>0, :total=>0}, :attachment=>nil })
        stub.should have_been_requested
        stub_pmcid_lookup.should_not have_been_requested
      end
      
      it "should report if there are no events and event_count returned by the PubMed API" do
        article_without_events = FactoryGirl.build(:article, :doi => "10.1371/journal.pone.0008776")
        stub_pmid_lookup = stub_request(:get, PubMed::EUTILS_URL + "term=#{article_without_events.doi}&field=DOI&db=pubmed&tool=#{PubMed::ToolID}").to_return(:body => File.read(fixture_path + 'pub_med_esearch_pmid_nil.xml'), :status => 200)
        stub_pmcid_lookup = stub_request(:get, PubMed::EUTILS_URL + "term=#{article_without_events.doi}&field=DOI&db=pmc&tool=#{PubMed::ToolID}").to_return(:body => File.read(fixture_path + 'pub_med_esearch_pmcid_nil.xml'), :status => 200)
        stub = stub_request(:get, pub_med.get_query_url(article_without_events)).to_return(:body => File.read(fixture_path + 'pub_med_nil.xml'), :status => 200)
        pub_med.get_data(article_without_events).should eq({ :events => [], :event_count => 0, :events_url=>"http://www.ncbi.nlm.nih.gov/sites/entrez?db=pubmed&cmd=link&LinkName=pubmed_pmc_refs&from_uid=1897483597", :event_metrics => {:pdf=>nil, :html=>nil, :shares=>nil, :groups=>nil, :comments=>nil, :likes=>nil, :citations=>0, :total=>0}, :attachment=>nil })
        stub.should have_been_requested
      end
    end
    
    context "use article with events" do
      let(:article) { FactoryGirl.build(:article, :doi => "10.1371/journal.pone.0000001", :pub_med => "17183631", :pub_med_central => "1762328") }
      let(:stub_pmid_lookup) { stub_request(:get, PubMed::EUTILS_URL + "db=pubmed&field=DOI&term=#{article.doi}&tool=#{PubMed::ToolID}").to_return(:body => File.read(fixture_path + 'pub_med_esearch_pmid.xml'), :status => 200) }
      let(:stub_pmcid_lookup) { stub_request(:get, PubMed::EUTILS_URL + "db=pmc&field=DOI&term=#{article.doi}&tool=#{PubMed::ToolID}").to_return(:body => File.read(fixture_path + 'pub_med_esearch_pmcid.xml'), :status => 200) }
    
      it "should report if there are events and event_count returned by the PubMed API" do
        stub = stub_request(:get, pub_med.get_query_url(article)).to_return(:body => File.read(fixture_path + 'pub_med.xml'), :status => 200)
        response = pub_med.get_data(article)
        response[:events].length.should eq(13)
        response[:event_count].should eq(13)
        response[:attachment][:data].should include(article.pub_med)
        event = response[:events].first
        event[:event_url].should eq("http://www.pubmedcentral.nih.gov/articlerender.fcgi?artid=" + event[:event])
        stub.should have_been_requested
      end
   
      it "should catch errors with the PubMed API" do
        stub = stub_request(:get, pub_med.get_query_url(article)).to_return(:status => [408, "Request Timeout"])
        pub_med.get_data(article).should be_nil
        stub.should have_been_requested
        ErrorMessage.count.should == 1
        error_message = ErrorMessage.first
        error_message.class_name.should eq("Net::HTTPRequestTimeOut")
        error_message.message.should include("Request Timeout")
        error_message.status.should == 408
        error_message.source_id.should == pub_med.id
      end
    end
  end
end
