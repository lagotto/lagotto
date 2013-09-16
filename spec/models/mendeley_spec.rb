require 'spec_helper'

describe Mendeley do
  let(:mendeley) { FactoryGirl.create(:mendeley) }

  it "should report that there are no events if the doi, pmid, mendeley uuid and title are missing" do
    article_without_ids = FactoryGirl.build(:article, :doi => "", :pub_med => "", :mendeley => "", :title => "")
    mendeley.get_data(article_without_ids).should eq({ :events => [], :event_count => nil })
  end

  context "use the Mendeley API for uuid lookup" do
    let(:article) { FactoryGirl.build(:article, :doi => "10.1371/journal.pone.0008776", :mendeley => "") }

    it "should return the Mendeley uuid by the Mendeley API" do
      stub = stub_request(:get, mendeley.get_query_url(article, "pmid")).to_return(:headers => { "Content-Type" => "application/json" }, :body => File.read(fixture_path + 'mendeley.json'), :status => 200)
      mendeley.get_mendeley_uuid(article).should eq("46cb51a0-6d08-11df-afb8-0026b95d30b2")
      stub.should have_been_requested
    end

    it "should return the Mendeley uuid by searching the Mendeley API" do
      article = FactoryGirl.build(:article, :doi => "10.1371/journal.pone.0000001", :mendeley => "")
      stub = stub_request(:get, mendeley.get_query_url(article, "pmid")).to_return(:headers => { "Content-Type" => "application/json" }, :body => File.read(fixture_path + 'mendeley_nil.json'), :status => 200)
      stub_doi = stub_request(:get, mendeley.get_query_url(article, "doi")).to_return(:headers => { "Content-Type" => "application/json" }, :body => File.read(fixture_path + 'mendeley_nil.json'), :status => 200)
      stub_title = stub_request(:get, mendeley.get_query_url(article, "title")).to_return(:headers => { "Content-Type" => "application/json" }, :body => File.read(fixture_path + 'mendeley_search.json'), :status => 200)
      mendeley.get_mendeley_uuid(article).should eq("1779af10-6d0c-11df-a2b2-0026b95e3eb7")
      stub.should have_been_requested
      stub_doi.should have_been_requested
      stub_title.should have_been_requested
    end

    it "should return nil for the Mendeley uuid if the Mendeley API returns malformed response" do
      stub = stub_request(:get, mendeley.get_query_url(article, "pmid")).to_return(:headers => { "Content-Type" => "application/json" }, :body => File.read(fixture_path + 'mendeley_nil.json'), :status => 200)
      stub_doi = stub_request(:get, mendeley.get_query_url(article, "doi")).to_return(:headers => { "Content-Type" => "application/json" }, :body => File.read(fixture_path + 'mendeley_nil.json'), :status => 200)
      stub_title = stub_request(:get, mendeley.get_query_url(article, "title")).to_return(:headers => { "Content-Type" => "application/json" }, :body => File.read(fixture_path + 'mendeley_search.json'), :status => 200)
      mendeley.get_mendeley_uuid(article).should be_nil
      stub.should have_been_requested
      stub_doi.should have_been_requested
      stub_title.should have_been_requested
      Alert.count.should == 0
    end

    it "should return nil for the Mendeley uuid if the Mendeley API returns incomplete response" do
      stub = stub_request(:get, mendeley.get_query_url(article, "pmid")).to_return(:headers => { "Content-Type" => "application/json" }, :body => File.read(fixture_path + 'mendeley_incomplete.json'), :status => 200)
      stub_doi = stub_request(:get, mendeley.get_query_url(article, "doi")).to_return(:headers => { "Content-Type" => "application/json" }, :body => File.read(fixture_path + 'mendeley_incomplete.json'), :status => 200)
      stub_title = stub_request(:get, mendeley.get_query_url(article, "title")).to_return(:headers => { "Content-Type" => "application/json" }, :body => File.read(fixture_path + 'mendeley_search.json'), :status => 200)
      mendeley.get_mendeley_uuid(article).should be_nil
      stub.should have_been_requested
      stub_doi.should have_been_requested
      stub_title.should have_been_requested
      Alert.count.should == 0
    end
  end

  context "use the Mendeley API for metrics" do
    it "should report if there are events and event_count returned by the Mendeley API" do
      article = FactoryGirl.build(:article, :doi => "10.1371/journal.pone.0008776", :mendeley => "46cb51a0-6d08-11df-afb8-0026b95d30b2")
      body = File.read(fixture_path + 'mendeley.json')
      stub = stub_request(:get, mendeley.get_query_url(article)).to_return(:headers => { "Content-Type" => "application/json" }, :body => body, :status => 200)
      stub_related = stub_request(:get, mendeley.get_related_url(article.mendeley)).to_return(:headers => { "Content-Type" => "application/json" }, :body => File.read(fixture_path + 'mendeley_related.json'), :status => 200)
      response = mendeley.get_data(article)
      response[:events].should be_true
      response[:events_url].should be_true
      response[:event_count].should eq(4)
      stub.should have_been_requested
    end

    it "should report no events and event_count if the Mendeley API returns incomplete response" do
      article = FactoryGirl.build(:article, :doi => "10.1371/journal.pone.0044294")
      stub = stub_request(:get, mendeley.get_query_url(article)).to_return(:headers => { "Content-Type" => "application/json" }, :body => File.read(fixture_path + 'mendeley_incomplete.json'), :status => 200)
      mendeley.get_data(article).should be_nil
      stub.should have_been_requested
      Alert.count.should == 0
    end

    it "should report no events and event_count if the Mendeley API returns malformed response" do
      article = FactoryGirl.build(:article, :doi => "10.1371/journal.pone.0044294")
      stub = stub_request(:get, mendeley.get_query_url(article)).to_return(:headers => { "Content-Type" => "application/json" }, :body => File.read(fixture_path + 'mendeley_nil.json'), :status => 404)
      mendeley.get_data(article).should be_nil
      stub.should have_been_requested
      Alert.count.should == 0
    end

    it "should report no events and event_count if the Mendeley API returns not found error" do
      article = FactoryGirl.build(:article)
      stub = stub_request(:get, mendeley.get_query_url(article)).to_return(:headers => { "Content-Type" => "application/json" }, :body => File.read(fixture_path + 'mendeley_error.json'), :status => 404)
      mendeley.get_data(article).should be_nil
      stub.should have_been_requested
      Alert.count.should == 0
    end

    it "should filter out the mendeley_authors attribute" do
      article = FactoryGirl.build(:article, :doi => "10.1371/journal.pbio.0020002", :mendeley => "83e9b290-6d01-11df-936c-0026b95e484c")
      body = File.read(fixture_path + 'mendeley_authors_tag.json')
      stub = stub_request(:get, mendeley.get_query_url(article)).to_return(:headers => { "Content-Type" => "application/json" }, :body => body, :status => 200)
      stub_related = stub_request(:get, mendeley.get_related_url(article.mendeley)).to_return(:headers => { "Content-Type" => "application/json" }, :body => File.read(fixture_path + 'mendeley_related.json'), :status => 200)
      response = mendeley.get_data(article)
      response[:events].should be_true
      response[:events]["mendeley_authors"].should be_nil
      response[:events_url].should be_true
      response[:event_count].should eq(29)
      stub.should have_been_requested
    end

    it "should catch errors with the Mendeley API" do
      article = FactoryGirl.build(:article, :doi => "10.1371/journal.pone.0000001")
      stub = stub_request(:get, mendeley.get_query_url(article)).to_return(:status => [408])
      mendeley.get_data(article, options = { :source_id => mendeley.id }).should be_nil
      stub.should have_been_requested
      Alert.count.should == 1
      alert = Alert.first
      alert.class_name.should eq("Net::HTTPRequestTimeOut")
      alert.status.should == 408
      alert.source_id.should == mendeley.id
    end
  end
end
