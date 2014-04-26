require 'spec_helper'

describe PubMed do
  let(:pub_med) { FactoryGirl.create(:pub_med) }

  it "should report that there are no events if the pmid is missing" do
    article = FactoryGirl.build(:article, :pmid => "")
    pubmed_url = "http://www.pubmedcentral.nih.gov/utils/idconv/v1.0/?ids=#{article.doi_escaped}&idtype=doi&format=json"
    stub = stub_request(:get, pubmed_url).to_return(:headers => { "Content-Type" => "application/json" }, :body => File.read(fixture_path + 'persistent_identifiers_nil.json'), :status => 200)
    pub_med.parse_data(article).should eq(events: [], event_count: nil)
  end

  context "use the PubMed API" do
    it "should report if there are no events and event_count returned by the PubMed API" do
      article = FactoryGirl.create(:article, :doi => "10.1371/journal.pone.0008776", :pmid => "1897483599", :pmcid => "2808249")
      stub = stub_request(:get, pub_med.get_query_url(article)).to_return(:body => File.read(fixture_path + 'pub_med_nil.xml'), :status => 200)
      pub_med.parse_data(article).should eq(events: [], event_count: 0, events_url: "http://www.ncbi.nlm.nih.gov/sites/entrez?db=pubmed&cmd=link&LinkName=pubmed_pmc_refs&from_uid=1897483599", event_metrics: { pdf: nil, html: nil, shares: nil, groups: nil, comments: nil, likes: nil, citations: 0, total: 0})
      stub.should have_been_requested
    end

    context "use article with events" do
      let(:article) { FactoryGirl.create(:article, :doi => "10.1371/journal.pone.0000001", :pmid => "17183631", :pmcid => "1762328") }

      it "should report if there are events and event_count returned by the PubMed API" do
        stub = stub_request(:get, pub_med.get_query_url(article)).to_return(:body => File.read(fixture_path + 'pub_med.xml'), :status => 200)
        response = pub_med.parse_data(article)
        response[:events].length.should eq(13)
        response[:event_count].should eq(13)
        event = response[:events].first
        event[:event_url].should eq("http://www.pubmedcentral.nih.gov/articlerender.fcgi?artid=" + event[:event])
        stub.should have_been_requested
      end

      it "should catch errors with the PubMed API" do
        stub = stub_request(:get, pub_med.get_query_url(article)).to_return(:status => [408])
        pub_med.parse_data(article, options = { :source_id => pub_med.id }).should be_nil
        stub.should have_been_requested
        Alert.count.should == 1
        alert = Alert.first
        alert.class_name.should eq("Net::HTTPRequestTimeOut")
        alert.status.should == 408
        alert.source_id.should == pub_med.id
      end
    end
  end
end
