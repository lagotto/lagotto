require 'rails_helper'

describe "api:snapshot:events" do
  include ActiveJob::TestHelper
  include_context "rake"

  let!(:source) { FactoryGirl.create(:source) }
  let(:output) { "Queuing a snapshot for /api/events\n" }

  it "prerequisites should include environment" do
    expect(subject.prerequisites).to include("environment")
  end

  it "should run the rake task" do
    expect(capture_stdout { subject.invoke }).to eq(output)
  end

  it "should enqueue an ApiSnapshotJob" do
    expect {
      capture_stdout { subject.invoke }
    }.to change(enqueued_jobs, :size).by(1)
    expect(enqueued_jobs.last[:job]).to be(ApiSnapshotJob)
  end
end

describe "api:snapshot:references" do
  include ActiveJob::TestHelper
  include_context "rake"

  let!(:source) { FactoryGirl.create(:source) }
  let(:output) { "Queuing a snapshot for /api/references\n" }

  it "prerequisites should include environment" do
    expect(subject.prerequisites).to include("environment")
  end

  it "should run the rake task" do
    expect(capture_stdout { subject.invoke }).to eq(output)
  end

  it "should enqueue an ApiSnapshotJob" do
    expect {
      capture_stdout { subject.invoke }
    }.to change(enqueued_jobs, :size).by(1)
    expect(enqueued_jobs.last[:job]).to be(ApiSnapshotJob)
  end
end

describe "api:snapshot:works" do
  include ActiveJob::TestHelper
  include_context "rake"

  let!(:source) { FactoryGirl.create(:source) }
  let(:output) { "Queuing a snapshot for /api/works\n" }

  it "prerequisites should include environment" do
    expect(subject.prerequisites).to include("environment")
  end

  it "should run the rake task" do
    expect(capture_stdout { subject.invoke }).to eq(output)
  end

  it "should enqueue an ApiSnapshotJob" do
    expect {
      capture_stdout { subject.invoke }
    }.to change(enqueued_jobs, :size).by(1)
    expect(enqueued_jobs.last[:job]).to be(ApiSnapshotJob)
  end

end
