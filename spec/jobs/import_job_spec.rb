require 'rails_helper'

RSpec.describe ImportJob, :type => :job do
  include ActiveJob::TestHelper

  it "enqueue jobs" do
    expect(enqueued_jobs.size).to eq(0)
    ImportJob.perform_later("CslImport")
    expect(enqueued_jobs.size).to eq(1)

    import_job = enqueued_jobs.first
    expect(import_job[:job]).to eq(ImportJob)
  end
end
