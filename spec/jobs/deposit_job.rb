require 'rails_helper'

RSpec.describe DepositJob, :type => :job do
  include ActiveJob::TestHelper

  let(:deposit) { FactoryGirl.create(:deposit) }

  it "enqueue jobs" do
    expect(deposit.human_state_name).to eq("waiting")
    expect(enqueued_jobs.size).to eq(1)

    deposit_job = enqueued_jobs.first
    expect(deposit_job).to eq(job: DepositJob, args: [{"_aj_globalid"=>"gid://lagotto/Deposit/1"}], queue: "default")
  end
end
