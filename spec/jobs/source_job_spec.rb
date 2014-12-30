require 'rails_helper'

RSpec.describe SourceJob, :type => :job do
  include ActiveJob::TestHelper

  let(:retrieval_status) { FactoryGirl.create(:retrieval_status) }
  let(:source) { FactoryGirl.create(:source) }

  it "enqueue jobs" do
    expect(enqueued_jobs.size).to eq(0)
    SourceJob.perform_later([retrieval_status.id], source)
    expect(enqueued_jobs.size).to eq(1)
  end
end
