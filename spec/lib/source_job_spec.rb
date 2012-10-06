require 'spec_helper'
require 'source_helper'

describe SourceJob do
  include SourceHelper
  
  before(:each) do
    #@retrieval_status = FactoryGirl.create(:retrieval_status)
  end
  
  it "should perform and get data" do
    #source_job = SourceJob.new([@retrieval_status.id], @retrieval_status.source.id)
    #source_job.perform_get_data(@retrieval_status.id)
  end
  
end