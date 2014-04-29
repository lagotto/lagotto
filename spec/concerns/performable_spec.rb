require 'spec_helper'

describe RetrievalStatus do

  subject { FactoryGirl.create(:retrieval_status) }

  let(:rs_id) { "#{subject.source.name}:#{subject.article.doi_escaped}" }

  before(:each) { subject.put_alm_database }
  after(:each) { subject.delete_alm_database }

  context "perform get data" do
    it "should perform and get DelayedJob timeout error" do
      # Alert.count.should == 1
      # alert = Alert.first
      # alert.class_name.should eq("Timeout::Error")
      # alert.message.should eq("SourceJob timeout error for CiteULike")
      # alert.status.should == 408
      # alert.source_id.should == source.id
    end

    it "should perform and get data" do
      stub = stub_request(:get, subject.source.get_query_url(subject.article)).to_return(:body => File.read(fixture_path + 'citeulike.xml'), :status => 200)
      result = subject.perform_get_data
      result[:event_count].should eq(25)
      rh_id = result[:retrieval_history_id]

      rs_result = subject.get_alm_data(rs_id)
      rs_result.should include("source" => subject.source.name,
                               "doi" => subject.article.doi,
                               "doc_type" => "current",
                               "_id" =>  "#{subject.source.name}:#{subject.article.doi}")
      rh_result = subject.get_alm_data(rh_id)
      rh_result.should include("source" => subject.source.name,
                               "doi" => subject.article.doi,
                               "doc_type" => "history",
                               "_id" => "#{rh_id}")
    end

    it "should perform and update CouchDB" do
      stub = stub_request(:get, subject.source.get_query_url(subject.article)).to_return(:body => File.read(fixture_path + 'citeulike.xml'), :status => 200)
      result = subject.perform_get_data
      rh_id = result[:retrieval_history_id]

      rs_result = subject.get_alm_data(rs_id)


      rs_result.should include("source" => subject.source.name,
                               "doi" => subject.article.doi,
                               "doc_type" => "current",
                               "_id" => "#{subject.source.name}:#{subject.article.doi}")
      rh_result = subject.get_alm_data(rh_id)
      rh_result.should include("source" => subject.source.name,
                               "doi" => subject.article.doi,
                               "doc_type" => "history",
                               "_id" => "#{rh_id}")

      new_result = subject.perform_get_data
      new_rh_id = new_result[:retrieval_history_id]
      new_rh_id.should_not eq(rh_id)

      new_rs_result = subject.get_alm_data(rs_id)
      new_rs_result.should include("source" => subject.source.name,
                                   "doi" => subject.article.doi,
                                   "doc_type" => "current",
                                   "_id" => "#{subject.source.name}:#{subject.article.doi}")
      new_rs_result["_rev"].should_not be_nil
      new_rs_result["_rev"].should_not eq(rs_result["_rev"])

      new_rh_result = subject.get_alm_data(new_rh_id)
      new_rh_result.should include("source" => subject.source.name,
                                   "doi" => subject.article.doi,
                                   "doc_type" => "history",
                                   "_id" => "#{new_rh_id}")
      new_rh_result["_rev"].should_not be_nil
      new_rh_result["_id"].should_not eq(rh_result["_id"])
    end

    it "should perform and get no data" do
      stub = stub_request(:get, subject.source.get_query_url(subject.article)).to_return(:body => File.read(fixture_path + 'citeulike_nil.xml'), :status => 200)
      result = subject.perform_get_data
      result[:event_count].should eq(0)
    end

    it "should perform and get skipped" do
      subject = FactoryGirl.create(:retrieval_status, :missing_mendeley)
      auth = ActionController::HttpAuthentication::Basic.encode_credentials(subject.source.client_id, subject.source.secret)
      scheduled_at = subject.scheduled_at
      stub_auth = stub_request(:post, subject.source.authentication_url).with(:headers => { :authorization => auth }, :body => "grant_type=client_credentials").to_return(:headers => { "Content-Type" => "application/json" }, :body => File.read(fixture_path + 'mendeley_auth.json'), :status => 200)
      stub = stub_request(:get, subject.source.get_lookup_url(subject.article, "doi")).to_return(:body => File.read(fixture_path + 'mendeley_nil.json'), :status => 200)
      stub_pmid = stub_request(:get, subject.source.get_lookup_url(subject.article)).to_return(:body => File.read(fixture_path + 'mendeley_nil.json'), :status => 200)
      stub_title = stub_request(:get, subject.source.get_lookup_url(subject.article, "title")).to_return(:body => File.read(fixture_path + 'mendeley_nil.json'), :status => 200)
      result = subject.perform_get_data
      result[:event_count].should eq(0)
      result[:retrieval_history_id].should be_nil
    end

    it "should perform and get error" do
      stub = stub_request(:get, subject.source.get_query_url(subject.article)).to_return(:status => [408])
      result = subject.perform_get_data
      result[:event_count].should be_nil
      result[:retrieval_history_id].should be_nil

      Alert.count.should == 1
      alert = Alert.first
      alert.class_name.should eq("Net::HTTPRequestTimeOut")
      alert.status.should == 408
      alert.source_id.should == subject.source.id
    end
  end
end
