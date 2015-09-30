require 'rails_helper'

RSpec.describe DataExportJob, :type => :job do
  include ActiveJob::TestHelper

  let(:data_export){ FactoryGirl.create(:data_export) }

  it "enqueues the job" do
    expect {
      DataExportJob.perform_later(id:1)
    }.to change(enqueued_jobs, :size).to(1)
  end

  describe "#perform" do
    before do
      allow(DataExport).to receive(:find_by_id!)
      allow(data_export).to receive(:export!)
    end

    it "finds the DataExport and tells it to #export!" do
      expect(DataExport).to receive(:find_by_id!).with(99).and_return data_export
      expect(data_export).to receive(:export!)
      DataExportJob.new.perform(id: 99)
    end

    context "and an error is raised during export" do
      before do
        allow(data_export).to receive(:export!).and_raise("BOOM")
      end

      it "logs the error as an Alert" do
        expect {
          DataExportJob.new.perform(id: 99)
        }.to change(Notification, :count).by(1)
      end
    end
  end
end
