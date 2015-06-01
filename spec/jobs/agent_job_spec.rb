require 'rails_helper'

RSpec.describe AgentJob, :type => :job do
  include ActiveJob::TestHelper

  let(:task) { FactoryGirl.create(:task) }
  let(:agent) { FactoryGirl.create(:agent) }

  it "enqueue jobs" do
    expect(enqueued_jobs.size).to eq(0)
    AgentJob.perform_later([task.id], agent)
    expect(enqueued_jobs.size).to eq(1)
  end
end
