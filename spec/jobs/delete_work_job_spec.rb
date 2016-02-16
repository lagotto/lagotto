require 'rails_helper'

RSpec.describe DeleteWorkJob, :type => :job do
  include ActiveJob::TestHelper

  let(:publisher) { FactoryGirl.create(:publisher) }

  it "enqueue jobs" do
    expect(enqueued_jobs.size).to eq(0)
    DeleteWorkJob.perform_later(publisher.name)
    expect(enqueued_jobs.size).to eq(1)
  end
end
