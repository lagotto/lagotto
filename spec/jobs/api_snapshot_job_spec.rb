require 'rails_helper'

RSpec.describe ApiSnapshotJob, :type => :job do
  include ActiveJob::TestHelper

  let(:api_snapshot){ FactoryGirl.create(:api_snapshot) }

  it "enqueues the job" do
    expect {
      ApiSnapshotJob.perform_later(id:1)
    }.to change(enqueued_jobs, :size).to(1)
  end

  describe "#perform" do
    before do
      allow(ApiSnapshot).to receive(:find_by_id!).and_return api_snapshot
      allow(api_snapshot).to receive(:snapshot!)
    end

    it "finds the DataExport and tells it to #snapshot!" do
      expect(ApiSnapshot).to receive(:find_by_id!).with(99).and_return api_snapshot
      expect(api_snapshot).to receive(:snapshot!)
      ApiSnapshotJob.new.perform(id: 99)
    end

    context "and an error is raised during snapshotting" do
      before do
        allow(api_snapshot).to receive(:snapshot!).and_raise("BOOM")
      end

      it "logs the error as an Alert" do
        expect {
          ApiSnapshotJob.new.perform(id: 99)
        }.to change(Alert, :count).by(1)
      end
    end

    context "and the snapshot isn't finished" do
      it "updates the snapshot to start at the next page" do
        api_snapshot.pageno = 4
        expect {
          ApiSnapshotJob.new.perform(id: 99)
        }.to change(api_snapshot, :start_page).to 5
      end

      it "updates the snapshot to operate in APPEND mode" do
        api_snapshot.mode = ApiSnapshot::CREATE_MODE
        expect {
          ApiSnapshotJob.new.perform(id: 99)
        }.to change(api_snapshot, :mode).to ApiSnapshot::APPEND_MODE
      end

      it "queues up another ApiSnapshotJob" do
        expect {
          ApiSnapshotJob.new.perform(id: 99)
        }.to change(enqueued_jobs, :size).by(+1)
      end
    end

    context "and the snapshot is finished with :upload_on_finished set to true" do
      before do
        allow(api_snapshot).to receive(:finished?).and_return true
        allow(ApiSnapshotUtility).to receive(:zip)
        allow(ApiSnapshotUtility).to receive(:export_to_zenodo)
      end

      it "zips the snapshot" do
        expect(ApiSnapshotUtility).to receive(:zip).with(api_snapshot)
        ApiSnapshotJob.new.perform(id: 99, upload_on_finished: true)
      end

      it "exports the zip to zZenodo" do
        expect(ApiSnapshotUtility).to receive(:export_to_zenodo).with(api_snapshot)
        ApiSnapshotJob.new.perform(id: 99, upload_on_finished: true)
      end
    end

    context "and the snapshot is finished with :upload_on_finished not set" do
      before do
        allow(api_snapshot).to receive(:finished?).and_return true
        allow(ApiSnapshotUtility).to receive(:zip)
        allow(ApiSnapshotUtility).to receive(:export_to_zenodo)
      end

      it "doesn't zip the snapshot" do
        expect(ApiSnapshotUtility).to_not receive(:zip).with(api_snapshot)
        ApiSnapshotJob.new.perform(id: 99)
      end

      it "doesn't exports the zip to Zenodo" do
        expect(ApiSnapshotUtility).to_not receive(:export_to_zenodo).with(api_snapshot)
        ApiSnapshotJob.new.perform(id: 99)
      end
    end

  end
end
