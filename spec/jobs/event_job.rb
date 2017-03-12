require 'rails_helper'

RSpec.describe EventJob, :type => :job do
  include ActiveJob::TestHelper

  let(:deposit) { FactoryGirl.create(:deposit) }

  it "enqueue jobs" do
    expect(event.human_state_name).to eq("waiting")
    expect(enqueued_jobs.size).to eq(1)

    event_job = enqueued_jobs.first
    expect(event_job[:job]).to eq(DepositJob)
  end
end
