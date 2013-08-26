require 'spec_helper'
require 'source_helper'

class SourceHelperClass
end

describe SourceJob do
  include SourceHelper

  before(:each) do
    @source_helper_class = SourceHelperClass.new
    @source_helper_class.extend(SourceHelper)

    @source_helper_class.put_alm_database
  end

  after(:each) do
    @source_helper_class.delete_alm_database
  end

  let(:retrieval_status) { FactoryGirl.create(:retrieval_status) }
  let(:source_job) { SourceJob.new([retrieval_status.id], retrieval_status.source.id) }
  let(:citeulike) { FactoryGirl.create(:citeulike) }
  let(:rs_id) { "#{retrieval_status.source.name}:#{retrieval_status.article.doi_escaped}" }

  it "should perform and get data" do
    stub = stub_request(:get, citeulike.get_query_url(retrieval_status.article)).to_return(:body => File.read(fixture_path + 'citeulike.xml'), :status => 200)
    result = source_job.perform_get_data(retrieval_status.id)
    rh = result[:retrieval_history]
    rh[:status].should eq("SUCCESS")
    rh[:event_count].should eq(25)
    rh[:retrieval_status_id].should eq(retrieval_status.id)

    rs_result = @source_helper_class.get_alm_data(rs_id)
    rs_result.should include("source" => retrieval_status.source.name,
                             "doi" => retrieval_status.article.doi,
                             "doc_type" => "current",
                             "_id" =>  "#{retrieval_status.source.name}:#{retrieval_status.article.doi}")
    rh_result = @source_helper_class.get_alm_data("#{rh[:id]}")
    rh_result.should include("source" => retrieval_status.source.name,
                             "doi" => retrieval_status.article.doi,
                             "doc_type" => "history",
                             "_id" => "#{rh[:id]}")
  end

  it "should perform and update CouchDB" do
    stub = stub_request(:get, citeulike.get_query_url(retrieval_status.article)).to_return(:body => File.read(fixture_path + 'citeulike.xml'), :status => 200)
    result = source_job.perform_get_data(retrieval_status.id)
    rh = result[:retrieval_history]

    rs_result = @source_helper_class.get_alm_data(rs_id)
    rs_result.should include("source" => retrieval_status.source.name,
                             "doi" => retrieval_status.article.doi,
                             "doc_type" => "current",
                             "_id" => "#{retrieval_status.source.name}:#{retrieval_status.article.doi}")
    rh_result = @source_helper_class.get_alm_data("#{rh[:id]}")
    rh_result.should include("source" => retrieval_status.source.name,
                             "doi" => retrieval_status.article.doi,
                             "doc_type" => "history",
                             "_id" => "#{rh[:id]}")

    new_result = source_job.perform_get_data(retrieval_status.id)
    new_rh = new_result[:retrieval_history]
    new_rh[:id].should_not eq(rh[:id])

    new_rs_result = @source_helper_class.get_alm_data(rs_id)
    new_rs_result.should include("source" => retrieval_status.source.name,
                                 "doi" => retrieval_status.article.doi,
                                 "doc_type" => "current",
                                 "_id" => "#{retrieval_status.source.name}:#{retrieval_status.article.doi}")
    new_rs_result["_rev"].should_not be_nil
    new_rs_result["_rev"].should_not eq(rs_result["_rev"])

    new_rh_result = @source_helper_class.get_alm_data("#{new_rh[:id]}")
    new_rh_result.should include("source" => retrieval_status.source.name,
                                 "doi" => retrieval_status.article.doi,
                                 "doc_type" => "history",
                                 "_id" => "#{new_rh[:id]}")
    new_rh_result["_rev"].should_not be_nil
    new_rh_result["_id"].should_not eq(rh_result["_id"])
  end

  it "should perform and get no data" do
    stub = stub_request(:get, citeulike.get_query_url(retrieval_status.article)).to_return(:body => File.read(fixture_path + 'citeulike_nil.xml'), :status => 200)
    result = source_job.perform_get_data(retrieval_status.id)
    rh = result[:retrieval_history]
    rh[:status].should eq("SUCCESS WITH NO DATA")
    rh[:event_count].should eq(0)
    rh[:retrieval_status_id].should eq(retrieval_status.id)
  end

  it "should perform and get skipped" do
    retrieval_status = FactoryGirl.create(:retrieval_status, :missing_mendeley)
    scheduled_at = retrieval_status.scheduled_at
    stub = stub_request(:get, retrieval_status.source.get_query_url(CGI.escape(retrieval_status.article.doi_escaped), "doi")).to_return(:body => File.read(fixture_path + 'mendeley_nil.json'), :status => 200)
    stub_pubmed = stub_request(:get, retrieval_status.source.get_query_url(retrieval_status.article.pub_med, "pmid")).to_return(:body => File.read(fixture_path + 'mendeley_nil.json'), :status => 200)
    stub_title = stub_request(:get, retrieval_status.source.get_query_url(CGI.escape(retrieval_status.article.title_escaped), "title")).to_return(:body => File.read(fixture_path + 'mendeley_nil.json'), :status => 200)
    result = source_job.perform_get_data(retrieval_status.id)
    rs = result[:retrieval_status]
    rs[:event_count].should eq(0)
    rs[:id].should eq(retrieval_status.id)
    rs[:scheduled_at].should_not eq(scheduled_at)
  end

  it "should perform and get error" do
    scheduled_at = retrieval_status.scheduled_at
    stub = stub_request(:get, citeulike.get_query_url(retrieval_status.article)).to_return(:status => [408])
    source_job.perform_get_data(retrieval_status.id).should be_nil
    ErrorMessage.count.should == 1
    error_message = ErrorMessage.first
    error_message.class_name.should eq("Net::HTTPRequestTimeOut")
    error_message.status.should == 408
    error_message.source_id.should == citeulike.id
  end
end
