require 'rails_helper'

describe "report:alm_stats" do
  include_context "rake"

  let!(:source) { FactoryGirl.create(:source) }
  let(:output) { "Report \"alm_stats.csv\" has been written.\n" }

  it "prerequisites should include environment" do
    expect(subject.prerequisites).to include("environment")
  end

  it "should run the rake task" do
    expect(capture_stdout { subject.invoke }).to eq(output)
  end
end

describe "report:alm_private_stats" do
  include_context "rake"

  let!(:source) { FactoryGirl.create(:source) }
  let(:output) { "Report \"alm_private_stats.csv\" has been written.\n" }

  it "prerequisites should include environment" do
    expect(subject.prerequisites).to include("environment")
  end

  it "should run the rake task" do
    expect(capture_stdout { subject.invoke }).to eq(output)
  end
end

describe "report:zip" do
  include_context "rake"

  let(:output_dir){ "#{Rails.root}/tmp/sample_reports" }
  let(:report_filename){ ReportWriter::ALM_COMBINED_STATS_FILENAME + "_#{Time.zone.now.to_date}.csv" }
  let(:report_filepath){ File.join output_dir, report_filename }

  before do
    Dir.mkdir output_dir unless Dir.exist? output_dir
    FileUtils.touch(report_filepath)

    # Must have a written report logged in order to zip files
    report = Object.new
    writer = ReportWriter.new(output_dir: output_dir)
    writer.write report, contents: "foo", filename: report_filename, output: StringIO.new
  end

  after do
    FileUtils.rm_rf output_dir if Dir.exist? output_dir
  end

  let!(:source) { FactoryGirl.create(:source) }
  let(:output) { "Reports have been compressed!" }

  it "prerequisites should include environment" do
    expect(subject.prerequisites).to include("environment")
  end

  it "should run the rake task" do
    expect(capture_stdout { subject.invoke }).to include(output)
  end
end
