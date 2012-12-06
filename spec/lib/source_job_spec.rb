require 'spec_helper'
require 'source_helper'

class SourceHelperClass
end

describe SourceJob do
  include SourceHelper
  
  before(:each) do
    @source_helper_class = SourceHelperClass.new
    @source_helper_class.extend(SourceHelper)
    
    #@source_helper_class.put_alm_database
  end
  
  after(:each) do
    #@source_helper_class.delete_alm_database
  end
  
  let(:retrieval_status) { FactoryGirl.create(:retrieval_status) }
  let(:source_job) { SourceJob.new([retrieval_status.id], retrieval_status.source.id) }
  let(:citeulike) { FactoryGirl.create(:citeulike) }
  
  it "should perform and get data" do
    stub = stub_request(:get, citeulike.get_query_url(retrieval_status.article)).to_return(:body => File.read(fixture_path + 'citeulike.xml'), :status => 200)
    #result = source_job.perform_get_data(retrieval_status.id)
    #rh = result[:retrieval_history]
    #rh[:status].should eq("SUCCESS")
    #rh[:event_count].should eq(25)
    #rh[:retrieval_status_id].should eq(retrieval_status.id)
  end
  
  it "should perform and get no data" do
    stub = stub_request(:get, citeulike.get_query_url(retrieval_status.article)).to_return(:body => File.read(fixture_path + 'citeulike_nil.xml'), :status => 200)
    #result = source_job.perform_get_data(retrieval_status.id)
    #rh = result[:retrieval_history]
    #rh[:status].should eq("SUCCESS WITH NO DATA")
    #rh[:event_count].should eq(0)
    #rh[:retrieval_status_id].should eq(retrieval_status.id)
  end
  
  it "should perform and get error" do
    stub = stub_request(:get, citeulike.get_query_url(retrieval_status.article)).to_return(:status => 408)
    #lambda { source_job.perform_get_data(retrieval_status.id) }.should raise_error(Net::HTTPServerException, /408/) 
  end
  
end