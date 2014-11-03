require 'rails_helper'

describe "workers:start" do
  include_context "rake"

  before do
    Worker.stop
  end

  let(:output) { "All #{ENV['WORKERS']} workers started.\n" }

  it "prerequisites should include environment" do
    expect(subject.prerequisites).to include("environment")
  end

  it "should run the rake task" do
    expect(capture_stdout { subject.invoke }).to eq(output)
  end
end

describe "workers:stop" do
  include_context "rake"

  before do
    Worker.start
  end

  let(:output) { "All workers stopped.\n" }

  it "should run" do
    expect(capture_stdout { subject.invoke }).to eq(output)
  end
end

describe "workers:monitor" do
  include_context "rake"

  before do
    Worker.stop
    @report = FactoryGirl.create(:missing_workers_report_with_admin_user)
  end

  after do
    Worker.stop
  end

  let(:message) { "Error monitoring workers, only 0 of #{ENV['WORKERS']} workers running. Workers restarted." }
  let(:output) { "#{message}\n#{ENV['WORKERS']} workers expected, #{ENV['WORKERS']} workers running.\n" }

  it "should run" do
    expect(capture_stdout { subject.invoke }).to eq(output)

    expect(Alert.count).to eq(1)
    alert = Alert.first
    expect(alert.class_name).to eq("StandardError")
    expect(alert.message).to eq(message)
  end
end
