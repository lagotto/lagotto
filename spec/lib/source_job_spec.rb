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

  it "should perform and get data" do
    stub = stub_request(:get, citeulike.get_query_url(retrieval_status.article)).to_return(:body => File.read(fixture_path + 'citeulike.xml'), :status => 200)
    result = source_job.perform_get_data(retrieval_status.id)
    rh = result[:retrieval_history]
    rh[:status].should eq("SUCCESS")
    rh[:event_count].should eq(25)
    rh[:retrieval_status_id].should eq(retrieval_status.id)
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
    stub = stub_request(:get, retrieval_status.source.get_query_url(Addressable::URI.encode(Addressable::URI.encode(retrieval_status.article.doi)), "doi")).to_return(:body => File.read(fixture_path + 'mendeley_nil.json'), :status => 200)
    stub_pubmed = stub_request(:get, retrieval_status.source.get_query_url(retrieval_status.article.pub_med, "pmid")).to_return(:body => File.read(fixture_path + 'mendeley_nil.json'), :status => 200)
    stub_title = stub_request(:get, retrieval_status.source.get_query_url(Addressable::URI.encode(Addressable::URI.encode(retrieval_status.article.title)), "title")).to_return(:body => File.read(fixture_path + 'mendeley_nil.json'), :status => 200)
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
    error_message.class_name.should eq("Faraday::Error::ClientError")
    error_message.status.should == 408
    error_message.source_id.should == citeulike.id
  end

end
