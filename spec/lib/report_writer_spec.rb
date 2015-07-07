require "rails_helper"

describe ReportWriter do
  subject(:report_writer){ ReportWriter.new(output_dir: output_dir) }
  let(:report){ double("Some Report") }
  let(:contents){ "" }
  let(:output_dir){ Rails.root.join("tmp/sample_reports").to_s }
  let(:filename){ "sample_report_file.txt" }

  def write_report
    report_writer.write(report, contents: contents, filename: filename)
  end

  describe '#write - write a report to disk' do
    let(:expected_filepath){ "#{output_dir}/#{filename}" }

    before do
      expect(File.exists?(expected_filepath)).to eq(false)
    end

    after do
      FileUtils.rm_rf(output_dir) if File.exists?(output_dir)
    end

    context "given a report, its contents, and a filename" do
      let(:contents){ "report contents here" }

      it "writes the report out to disk" do
        write_report
        expect(File.exists?(expected_filepath)).to be(true)
      end

      it "creates a ReportWriteLog record of the report written" do
        expect {
          write_report
        }.to change(ReportWriteLog, :count).by(1)

        log_record = ReportWriteLog.last
        expect(log_record.filepath).to eq(expected_filepath)
        expect(log_record.report_type).to eq(report.class.name)
      end
    end

    context "given empty contents" do
      let(:contents){ "" }

      it "doesn't write the report out to disk" do
        write_report
        expect(File.exists?(expected_filepath)).to be(false)
      end

      it "doesn't create a ReportWriteLog record" do
        expect {
          write_report
        }.to_not change(ReportWriteLog, :count)
      end
    end

    context "required arguments" do
      it "raises an ArgumentError without :filename" do
        expect{ report_writer.write(report, contents: contents) }.to raise_error(ArgumentError, "Must supply :filename")
      end

      it "raises an ArgumentError without :contents" do
        expect{ report_writer.write(report, filename: filename) }.to raise_error(ArgumentError, "Must supply :contents")
      end
    end
  end
end
