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

describe "report:mendeley_stats" do
  include_context "rake"

  let!(:mendeley) { FactoryGirl.create(:mendeley) }
  let(:output) { "Report \"mendeley_stats.csv\" has been written.\n" }

  it "prerequisites should include environment" do
    expect(subject.prerequisites).to include("environment")
  end

  it "should run the rake task" do
    expect(capture_stdout { subject.invoke }).to eq(output)
  end
end

describe "report:pmc_stats" do
  include_context "rake"

  let!(:pmc) { FactoryGirl.create(:pmc) }
  let(:output) { "Report \"pmc_stats.csv\" has been written.\n" }

  it "prerequisites should include environment" do
    expect(subject.prerequisites).to include("environment")
  end

  it "should run the rake task" do
    expect(capture_stdout { subject.invoke }).to eq(output)
  end
end

describe "report:pmc_html_stats" do
  include_context "rake"

  let!(:pmc) { FactoryGirl.create(:pmc) }
  let(:output) { "Report \"pmc_html.csv\" has been written.\n" }

  it "prerequisites should include environment" do
    expect(subject.prerequisites).to include("environment")
  end

  it "should run the rake task" do
    expect(capture_stdout { subject.invoke }).to eq(output)
  end
end

describe "report:pmc_pdf_stats" do
  include_context "rake"

  let!(:pmc) { FactoryGirl.create(:pmc) }
  let(:output) { "Report \"pmc_pdf.csv\" has been written.\n" }

  it "prerequisites should include environment" do
    expect(subject.prerequisites).to include("environment")
  end

  it "should run the rake task" do
    expect(capture_stdout { subject.invoke }).to eq(output)
  end
end

describe "report:pmc_combined_stats" do
  include_context "rake"

  let!(:pmc) { FactoryGirl.create(:pmc) }
  let(:output) { "Report \"pmc_combined.csv\" has been written.\n" }

  it "prerequisites should include environment" do
    expect(subject.prerequisites).to include("environment")
  end

  it "should run the rake task" do
    expect(capture_stdout { subject.invoke }).to eq(output)
  end
end

describe "report:counter_stats" do
  include_context "rake"

  let!(:counter) { FactoryGirl.create(:counter) }
  let(:output) { "Report \"counter_stats.csv\" has been written.\n" }

  it "prerequisites should include environment" do
    expect(subject.prerequisites).to include("environment")
  end

  it "should run the rake task" do
    expect(capture_stdout { subject.invoke }).to eq(output)
  end
end

describe "report:counter_html_stats" do
  include_context "rake"

  let!(:counter) { FactoryGirl.create(:counter) }
  let(:output) { "Report \"counter_html.csv\" has been written.\n" }

  it "prerequisites should include environment" do
    expect(subject.prerequisites).to include("environment")
  end

  it "should run the rake task" do
    expect(capture_stdout { subject.invoke }).to eq(output)
  end
end

describe "report:counter_pdf_stats" do
  include_context "rake"

  let!(:counter) { FactoryGirl.create(:counter) }
  let(:output) { "Report \"counter_pdf.csv\" has been written.\n" }

  it "prerequisites should include environment" do
    expect(subject.prerequisites).to include("environment")
  end

  it "should run the rake task" do
    expect(capture_stdout { subject.invoke }).to eq(output)
  end
end

describe "report:counter_xml_stats" do
  include_context "rake"

  let!(:counter) { FactoryGirl.create(:counter) }
  let(:output) { "Report \"counter_xml.csv\" has been written.\n" }

  it "prerequisites should include environment" do
    expect(subject.prerequisites).to include("environment")
  end

  it "should run the rake task" do
    expect(capture_stdout { subject.invoke }).to eq(output)
  end
end

describe "report:counter_combined_stats" do
  include_context "rake"

  let!(:counter) { FactoryGirl.create(:counter) }
  let(:output) { "Report \"counter_combined.csv\" has been written.\n" }

  it "prerequisites should include environment" do
    expect(subject.prerequisites).to include("environment")
  end

  it "should run the rake task" do
    expect(capture_stdout { subject.invoke }).to eq(output)
  end
end

describe "report:combined_stats" do
  include_context "rake"

  let!(:source) { FactoryGirl.create(:source) }
  let(:output) { "Report \"alm_report.csv\" has been written.\n" }

  it "prerequisites should include environment" do
    expect(subject.prerequisites).to include("environment")
  end

  it "should run the rake task" do
    ENV['PRIVATE'] = nil
    expect(capture_stdout { subject.invoke }).to eq(output)
  end
end

describe "report:combined_private_stats" do
  include_context "rake"

  let!(:source) { FactoryGirl.create(:source) }
  let(:output) { "Report \"alm_private_report.csv\" has been written.\n" }

  it "prerequisites should include environment" do
    expect(subject.prerequisites).to include("environment")
  end

  it "should run the rake task" do
    expect(capture_stdout { subject.invoke }).to eq(output)
  end
end

describe "report:zip" do
  include_context "rake"

  before do
    folderpath = "#{Rails.root}/data/report_#{Time.zone.now.to_date}"
    Dir.mkdir folderpath unless Dir.exist? folderpath
    FileUtils.touch("#{folderpath}/alm_report.csv")
  end

  let!(:source) { FactoryGirl.create(:source) }
  let(:output) { "Reports have been compressed.\n" }

  it "prerequisites should include environment" do
    expect(subject.prerequisites).to include("environment")
  end

  it "should run the rake task" do
    expect(capture_stdout { subject.invoke }).to eq(output)
  end
end
