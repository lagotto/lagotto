require "rails_helper"

describe ReportWriteLog do

  describe ".most_recent_with_name" do
    let!(:record_foo_1){ ReportWriteLog.create!(filepath:"/path/foo.txt", created_at: 5.minutes.ago) }
    let!(:record_foo_2){ ReportWriteLog.create!(filepath:"/path/foo.txt", created_at: 1.minute.ago) }
    let!(:record_bar_3){ ReportWriteLog.create!(filepath:"/path/bar.txt", created_at: 1.minute.ago) }

    it "returns the most recent record whose filename matches the given name" do
      record = ReportWriteLog.most_recent_with_name("foo.txt")
      expect(record).to eq(record_foo_2)
    end

    it "only matches on exact filename matches, not partial" do
      record = ReportWriteLog.most_recent_with_name("foo")
      expect(record).to be(nil)
    end
  end

  describe "validations" do
    subject(:report_write_log){ ReportWriteLog.new(filepath:"/path/foo") }

    it "is valid" do
      expect(report_write_log.valid?).to be(true)
    end

    it "requires :filepath" do
      report_write_log.filepath = nil
      expect(report_write_log.valid?).to be(false)
    end
  end

end
