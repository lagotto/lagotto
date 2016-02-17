require 'rails_helper'

RSpec.describe StatusCacheJob, :type => :job do
  include ActiveJob::TestHelper

  it "enqueue jobs" do
    expect(enqueued_jobs.size).to eq(0)
    StatusCacheJob.perform_later
    expect(enqueued_jobs.size).to eq(1)

    status_cache_job = enqueued_jobs.first
    expect(status_cache_job[:job]).to eq(StatusCacheJob)
  end
end
