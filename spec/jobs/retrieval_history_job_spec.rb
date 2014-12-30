require 'rails_helper'

RSpec.describe RetrievalHistoryJob, :type => :job do
  include ActiveJob::TestHelper

  let(:retrieval_history) { FactoryGirl.create(:retrieval_history) }

  it "enqueue jobs" do
    expect(enqueued_jobs.size).to eq(0)
    RetrievalHistoryJob.perform_later([retrieval_history.id])
    expect(enqueued_jobs.size).to eq(1)
  end
end
