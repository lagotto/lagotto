require 'spec_helper'

describe Source do
  
  before do
    @source = FactoryGirl.create(:source)
  end
  
  it { should belong_to(:group) }
  it { should have_many(:retrieval_statuses).dependent(:destroy) }
  
  it { should validate_presence_of(:display_name) }
  it { should validate_numericality_of(:timeout) }
  it { should validate_numericality_of(:workers) }
  it { should validate_numericality_of(:wait_time) }
end

