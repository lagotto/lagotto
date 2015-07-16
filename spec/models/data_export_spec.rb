require "rails_helper"

describe DataExport do
  subject(:data_export){ FactoryGirl.build(:data_export) }

  describe "#previous_version" do
    subject(:data_export){ FactoryGirl.create(:data_export, name: report_name) }
    let!(:report_name){ "MyReport" }
    let!(:export_one_week_ago){ FactoryGirl.create(:data_export,
      name: report_name,
      created_at: 1.week.ago,
      finished_exporting_at: 1.week.ago
    )}

    it "finds the previously exported version of this export type with the same name" do
      expect(data_export.previous_version).to eq(export_one_week_ago)
    end

    context "and the most recent export is not finished" do
      before { export_one_week_ago.update_attribute :finished_exporting_at, nil }

      it "does not consider unfinished exports as previous versions" do
        expect(data_export.previous_version).to_not eq(export_one_week_ago)
      end
    end

    context "and there are multiple previous exports with this name" do
      let!(:export_one_month_ago){ FactoryGirl.create(:data_export,
        name: report_name,
        created_at: 1.month.ago
      )}

      it "returns the most recent one" do
        expect(data_export.previous_version).to eq(export_one_week_ago)
      end
    end

    context "and there is a more recent export of a different type with the same name" do
      let!(:different_kind_one_day_ago){ FactoryGirl.create(:zenodo_data_export,
        name: report_name,
        created_at: 1.day.ago
      )}

      it "only returns reports of the same type" do
        expect(data_export.previous_version).to eq(export_one_week_ago)
      end
    end

    context "and there are no previous versions" do
      it "returns nil" do
        expect(export_one_week_ago.previous_version).to be(nil)
      end
    end
  end

  describe "#state" do
    it "is 'pending' when not started, finished, or failed" do
      expect(data_export.state).to eq("pending")
    end

    it "is 'processing' when started, but not finished or failed" do
      data_export.started_exporting_at = Time.zone.now
      expect(data_export.state).to eq("processing")
    end

    it "is 'done' when finished" do
      data_export.finished_exporting_at = Time.zone.now
      expect(data_export.state).to eq("done")
    end

    it "is 'failed' when failed"do
      data_export.failed_at = Time.zone.now
      expect(data_export.state).to eq("failed")
    end

  end
end
