require 'spec_helper'

describe Source do
  
  before do
    @source = FactoryGirl.build(:source)
  end
  
  it { should belong_to(:group) }
  it { should have_many(:retrieval_statuses).dependent(:destroy) }
  
  it { should validate_presence_of(:display_name) }
  it { should validate_numericality_of(:workers) }
  it { should ensure_inclusion_of(:workers).in_range(1..10).with_message("is not in the allowed range") }
  it { should validate_numericality_of(:timeout) }
  it { should ensure_inclusion_of(:timeout).in_range(1..3600).with_message("is not in the allowed range") }
  it { should validate_numericality_of(:wait_time) }
  it { should ensure_inclusion_of(:wait_time).in_range(1..3600).with_message("is not in the allowed range") }
  it { should validate_numericality_of(:max_failed_queries) }
  it { should ensure_inclusion_of(:max_failed_queries).in_range(0..1000).with_message("is not in the allowed range") }
  it { should validate_numericality_of(:max_failed_query_time_interval) }
  it { should ensure_inclusion_of(:max_failed_query_time_interval).in_range(0..864000).with_message("is not in the allowed range") }
end