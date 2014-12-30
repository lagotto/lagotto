require 'rails_helper'

RSpec.describe ImportJob, :type => :job do
  include ActiveJob::TestHelper

  it "enqueue jobs" do
    expect(enqueued_jobs.size).to eq(0)
    ImportJob.perform_later("CslImport")
    expect(enqueued_jobs.size).to eq(1)
  end
end
