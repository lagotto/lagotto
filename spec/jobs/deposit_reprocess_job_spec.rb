require 'rails_helper'

RSpec.describe DepositReprocessJob, :type => :job do
  include ActiveJob::TestHelper

  let(:deposit) { FactoryGirl.create(:deposit, state: 2) }

  it "enqueue jobs" do
    expect(enqueued_jobs.size).to eq(0)
    DepositReprocessJob.perform_later([deposit.id])
    expect(enqueued_jobs.size).to eq(1)

    deposit_reprocess_job = enqueued_jobs.last
    expect(deposit_reprocess_job[:job]).to eq(DepositReprocessJob)
  end
end
