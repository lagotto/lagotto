require 'spec_helper'

describe SourceJob do

  let(:retrieval_status) { FactoryGirl.create(:retrieval_status) }
  let(:citeulike) { FactoryGirl.create(:citeulike) }
  let(:rs_id) { "#{retrieval_status.source.name}:#{retrieval_status.article.doi_escaped}" }
  let(:error) {{ "error" => "not_found", "reason" => "missing" }}

  subject { SourceJob.new([retrieval_status.id], citeulike.id) }

  before(:each) do
    subject.put_alm_database
    Time.stub(:now).and_return(Time.mktime(2013,9,5))
  end

  after(:each) do
    subject.delete_alm_database
  end

  it "should perform and get DelayedJob timeout error" do
    subject.should_receive(:perform_get_data).and_raise(Timeout::Error)
    result = subject.perform

    Alert.count.should == 1
    alert = Alert.first
    alert.class_name.should eq("Timeout::Error")
    alert.message.should eq("SourceJob timeout error for CiteULike")
    alert.status.should == 408
    alert.source_id.should == citeulike.id
  end

  it "should perform and get data" do
    stub = stub_request(:get, citeulike.get_query_url(retrieval_status.article)).to_return(:body => File.read(fixture_path + 'citeulike.xml'), :status => 200)
    result = subject.perform_get_data(retrieval_status)
    result[:event_count].should eq(25)

    rs_result = subject.get_alm_data(rs_id)
    rs_result.should include("source" => retrieval_status.source.name,
                             "doi" => retrieval_status.article.doi,
                             "history" => [{ "id"=>"citeulike:10.1371%2Fjournal.pone.000002:#{Time.zone.now.utc.iso8601}", "event_count"=>25 }],
                             "retrieved_at" => Time.zone.now.utc.iso8601,
                             "doc_type" => "current",
                             "_id" =>  "#{retrieval_status.source.name}:#{retrieval_status.article.doi}")
  end

  it "should perform and update CouchDB" do
    stub = stub_request(:get, citeulike.get_query_url(retrieval_status.article)).to_return(:body => File.read(fixture_path + 'citeulike.xml'), :status => 200)
    result = subject.perform_get_data(retrieval_status)

    rs_result = subject.get_alm_data(rs_id)
    rs_result.should include("source" => retrieval_status.source.name,
                             "doi" => retrieval_status.article.doi,
                             "history" => [{ "id"=>"citeulike:10.1371%2Fjournal.pone.000003:#{Time.zone.now.utc.iso8601}", "event_count"=>25 }],
                             "retrieved_at" => Time.zone.now.utc.iso8601,
                             "doc_type" => "current",
                             "_id" => "#{retrieval_status.source.name}:#{retrieval_status.article.doi}")

    new_result = subject.perform_get_data(retrieval_status)

    new_rs_result = subject.get_alm_data(rs_id)
    new_rs_result.should include("source" => retrieval_status.source.name,
                                 "doi" => retrieval_status.article.doi,
                                 "history" => [{"id"=>"citeulike:10.1371%2Fjournal.pone.000003:#{Time.zone.now.utc.iso8601}", "event_count"=>25},
                                               {"id"=>"citeulike:10.1371%2Fjournal.pone.000003:#{Time.zone.now.utc.iso8601}", "event_count"=>25}],
                                 "doc_type" => "current",
                                 "_id" => "#{retrieval_status.source.name}:#{retrieval_status.article.doi}")
    new_rs_result["_rev"].should_not be_nil
    new_rs_result["_rev"].should_not eq(rs_result["_rev"])
  end

  it "should perform and get no data" do
    stub = stub_request(:get, citeulike.get_query_url(retrieval_status.article)).to_return(:body => File.read(fixture_path + 'citeulike_nil.xml'), :status => 200)
    result = subject.perform_get_data(retrieval_status)
    result[:event_count].should eq(0)
    JSON.parse(subject.get_alm_data(rs_id)).should eq(error)
  end

  it "should perform and get skipped" do
    retrieval_status = FactoryGirl.create(:retrieval_status, :missing_mendeley)
    scheduled_at = retrieval_status.scheduled_at
    stub = stub_request(:get, retrieval_status.source.get_query_url(retrieval_status.article, "doi")).to_return(:body => File.read(fixture_path + 'mendeley_nil.json'), :status => 200)
    stub_pubmed = stub_request(:get, retrieval_status.source.get_query_url(retrieval_status.article, "pmid")).to_return(:body => File.read(fixture_path + 'mendeley_nil.json'), :status => 200)
    stub_title = stub_request(:get, retrieval_status.source.get_query_url(retrieval_status.article, "title")).to_return(:body => File.read(fixture_path + 'mendeley_nil.json'), :status => 200)
    result = subject.perform_get_data(retrieval_status)
    result[:event_count].should eq(0)
    JSON.parse(subject.get_alm_data(rs_id)).should eq(error)
  end

  it "should perform and get error" do
    scheduled_at = retrieval_status.scheduled_at
    stub = stub_request(:get, citeulike.get_query_url(retrieval_status.article)).to_return(:status => [408])
    result = subject.perform_get_data(retrieval_status)
    result[:event_count].should be_nil
    JSON.parse(subject.get_alm_data(rs_id)).should eq(error)

    Alert.count.should == 1
    alert = Alert.first
    alert.class_name.should eq("Net::HTTPRequestTimeOut")
    alert.status.should == 408
    alert.source_id.should == citeulike.id
  end
end