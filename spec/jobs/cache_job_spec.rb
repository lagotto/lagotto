require 'rails_helper'

RSpec.describe CacheJob, :type => :job do
  include ActiveJob::TestHelper

  let(:source) { FactoryGirl.create(:source) }

  it "enqueue jobs" do
    expect(enqueued_jobs.size).to eq(0)
    CacheJob.perform_later(source)
    expect(enqueued_jobs.size).to eq(1)
  end
end
