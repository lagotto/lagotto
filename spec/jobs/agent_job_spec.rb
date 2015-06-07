require 'rails_helper'

RSpec.describe AgentJob, :type => :job do
  include ActiveJob::TestHelper

  let(:work) { FactoryGirl.create(:work) }
  let(:agent) { FactoryGirl.create(:agent) }

  it "enqueue jobs" do
    expect(enqueued_jobs.size).to eq(0)
    AgentJob.perform_later([work.id], agent)
    expect(enqueued_jobs.size).to eq(1)
  end
end
