require 'rails_helper'

shared_examples_for "a rake task that requires SERVERNAME env var" do
  it "should error if SERVERNAME env var is not set" do
    without_env("SERVERNAME") do
      expect {
        without_env("SERVERNAME"){ subject.invoke }
      }.to raise_error("SERVERNAME env variable must be set!")
    end
  end
end

describe "api:snapshot:events" do
  include WithEnv
  include ActiveJob::TestHelper
  include_context "rake"

  let!(:source) { FactoryGirl.create(:source) }
  let(:output) { "Queuing a snapshot for /api/events\n" }

  include_examples "a rake task that requires SERVERNAME env var"

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
  include WithEnv
  include ActiveJob::TestHelper
  include_context "rake"

  let!(:source) { FactoryGirl.create(:source) }
  let(:output) { "Queuing a snapshot for /api/references\n" }

  include_examples "a rake task that requires SERVERNAME env var"

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
  include WithEnv
  include ActiveJob::TestHelper
  include_context "rake"

  let!(:source) { FactoryGirl.create(:source) }
  let(:output) { "Queuing a snapshot for /api/works\n" }

  include_examples "a rake task that requires SERVERNAME env var"

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
