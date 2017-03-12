require 'rails_helper'

RSpec.describe EventReprocessJob, :type => :job do
  include ActiveJob::TestHelper

  let(:event) { FactoryGirl.create(:event, state: 2) }

  it "enqueue jobs" do
    expect(enqueued_jobs.size).to eq(0)
    EventReprocessJob.perform_later([event.id])
    expect(enqueued_jobs.size).to eq(2)

    event_reprocess_job = enqueued_jobs.last
    expect(event_reprocess_job[:job]).to eq(EventReprocessJob)
  end
end
