require 'spec_helper'
require 'source_helper'

describe SourceHelper do
  include SourceHelper
  
  # before(:each) do
  #   @retrieval_status = FactoryGirl.build(:retrieval_status)
  #   @id = "#{@retrieval_status.source.name}:#{CGI.escape(@retrieval_status.article.doi)}"
  #   @data = ActiveSupport::JSON.decode(File.read(fixture_path + 'source_helper.json'))
  #   @data_rev = save_alm_data(nil, @data.clone, @id)
  # end
  #          
  # it "should get ALM data from CouchDB" do
  #   data = get_alm_data(@id)
  #   data["events"].should eq @data["events"]
  # end
  # 
  # it "should remove ALM data from CouchDB" do
  #   data_rev = remove_alm_data(@data_rev, @id)
  #   data_rev.should_not equal @data_rev
  # end

end