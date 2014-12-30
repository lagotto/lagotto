require 'rails_helper'

RSpec.describe StatusCacheJob, :type => :job do
  include ActiveJob::TestHelper

  it "enqueue jobs" do
    expect(enqueued_jobs.size).to eq(0)
    StatusCacheJob.perform_later
    expect(enqueued_jobs.size).to eq(1)
  end
end
