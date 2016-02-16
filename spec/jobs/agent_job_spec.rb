require 'rails_helper'

RSpec.describe AgentJob, :type => :job do
  include ActiveJob::TestHelper

  let(:work) { FactoryGirl.create(:work) }
  let(:agent) { FactoryGirl.create(:agent) }

  it "enqueue jobs" do
    expect(enqueued_jobs.size).to eq(0)
    AgentJob.perform_later(agent, ids: [work.id])
    expect(enqueued_jobs.size).to eq(2)

    cache_job = enqueued_jobs.first
    expect(cache_job).to eq(job: CacheJob, args: [{"_aj_globalid"=>"gid://lagotto/Citeulike/1"}], queue: "critical")

    agent_job = enqueued_jobs.last
    expect(agent_job).to eq(job: AgentJob, args: [{"_aj_globalid"=>"gid://lagotto/Citeulike/1"}, {"ids"=>[1], "_aj_symbol_keys"=>["ids"]}], queue: "default")
  end
end
