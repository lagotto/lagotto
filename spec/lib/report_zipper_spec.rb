require "rails_helper"

describe ReportZipper do
  let(:data_dir){ Rails.root.join("tmp/sample_data_dir") }

  before do
    ReportWriter.data_dir = data_dir
    FileUtils.mkdir data_dir unless File.exists?(data_dir)
  end

  after do
    FileUtils.rm_rf data_dir if File.exists?(data_dir)
  end

  describe '.zip_alm_combined_stats!' do
    let!(:report_write_log){ ReportWriteLog.create!(filepath: report_filepath) }
    let(:report_filepath){ data_dir.join(report_filename) }
    let(:report_filename){ ReportWriter::ALM_COMBINED_STATS_CSV_FILENAME }

    before do
      File.write(report_filepath, "sample report contents")
    end

    after do
      FileUtils.rm(report_filepath) if File.exists?(report_filepath)
    end

    it "zips up the ALM combined stats report and stores it on disk" do
      zip_filepath = ReportZipper.zip_alm_combined_stats!
      expect(File.exists?(zip_filepath)).to be(true)

      zip_file = Zip::File.open(zip_filepath)
      expect(zip_file.get_entry(report_filename)).to_not be(nil)
    end

    it "includes the appropriate README.md" do
      zip_filepath = ReportZipper.zip_alm_combined_stats!
      zip_file = Zip::File.open(zip_filepath)

      expect(zip_file.get_entry("README.md")).to_not be(nil)

      expected_contents = File.read Rails.root.join("docs/readmes/alm_combined_stats_report.md")
      readme_entry = zip_file.get_entry("README.md")
      expect(readme_entry.get_input_stream.read).to eq(expected_contents)
    end

    context "and there is no log of a written ALM combined stats report" do
      before { report_write_log.destroy }

      it "raises a ReportZipper::ReportWriteLogNotFoundError" do
        expect {
          ReportZipper.zip_alm_combined_stats!
        }.to raise_error(ReportZipper::ReportWriteLogNotFoundError, "ReportWriteLog record not found for #{report_filename} filename")
      end
    end

    context "and the file written in the report's log doesn't exist" do
      before do
        FileUtils.rm(report_filepath)
      end

      it "raises a ReportZipper::FileNotFoundError" do
        expect {
          ReportZipper.zip_alm_combined_stats!
        }.to raise_error(ReportZipper::FileNotFoundError, /File not found at #{report_filepath} for/)
      end
    end
  end

  describe '.zip_administrative_reports!' do
    let(:report_dir){ data_dir.join("report_2015-05-09") }
    let(:report_filenames){ [file_foo, file_bar] }
    let(:file_foo){ "foo.txt" }
    let(:file_bar){ "bar.txt" }

    before do
      FileUtils.mkdir(report_dir)
      File.write report_dir.join(file_foo), "sample foo contents"
      File.write report_dir.join(file_bar), "sample bar contents"
    end

    after do
      FileUtils.rm_rf(report_dir) if File.exists?(report_dir)
    end

    it "zips up the most recent report_YYYY-MM-DD directory and stores it on disk" do
      zip_filepath = ReportZipper.zip_administrative_reports!
      expect(File.exists?(zip_filepath)).to be(true)

      zip_file = Zip::File.open(zip_filepath)
      expect(zip_file.get_entry(file_foo)).to_not be(nil)
      expect(zip_file.get_entry(file_bar)).to_not be(nil)
    end

    context "and there is no report_YYYY-MM-DD directory on disk" do
      before { FileUtils.rm_rf(report_dir) }

      it "raises a ReportZipper::FileNotFoundError" do
        expect {
          ReportZipper.zip_administrative_reports!
        }.to raise_error(ReportZipper::FileNotFoundError, "No report_YYYY-MM-DD directory found!")
      end
    end
  end

end
