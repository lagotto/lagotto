require 'rails_helper'

describe Report, type: :model, vcr: true, sidekiq: :inline do
  subject { Report }

  context "available reports" do

    before(:each) do
      FactoryGirl.create(:error_report_with_admin_user)
    end

    it "admin users should see one report" do
      response = subject.available("admin")
      expect(response.length).to eq(1)
    end

    it "regular users should not see any report" do
      response = subject.available("user")
      expect(response.length).to eq(0)
    end
  end

  describe '.write - write a report to disk' do
    subject(:write_report){ Report.write(report, contents: contents, filepath: filepath) }
    let(:report){ double("Some Report") }
    let(:contents){ "" }
    let(:filepath){ Rails.root.join("tmp/sample_report_file.txt").to_s }

    before do
      expect(File.exists?(filepath)).to eq(false)
    end

    after do
      FileUtils.rm(filepath) if File.exist?(filepath)
    end

    context "given a report, its contents, and a filepath" do
      let(:contents){ "report contents here" }

      it "writes the report out to disk" do
        write_report
        expect(File.exists?(filepath)).to be(true)
      end

      it "creates a ReportWriteLog record of the report written" do
        expect {
          write_report
        }.to change(ReportWriteLog, :count).by(1)

        log_record = ReportWriteLog.last
        expect(log_record.filepath).to eq(filepath)
        expect(log_record.report_type).to eq(report.class.name)
      end
    end

    context "given empty contents" do
      let(:contents){ "" }

      it "doesn't write the report out to disk" do
        write_report
        expect(File.exists?(filepath)).to be(true)
      end

      it "doesn't create a ReportWriteLog record" do
        expect {
          write_report
        }.to_not change(ReportWriteLog, :count)
      end
    end

    context "required arguments" do
      it "raises an ArgumentError without :contents" do
        expect{ Report.write(report, filepath: filepath) }.to raise_error(ArgumentError)
      end

      it "raises an ArgumentError without :filepath" do
        expect{ Report.write(report, filepath: filepath) }.to raise_error(ArgumentError)
      end
    end


  end


  #
  #   before(:each) do
  #     FileUtils.rm_rf("#{Rails.root}/data/report_#{Time.zone.now.to_date.iso8601}")
  #   end
  #
  #   let!(:work) { FactoryGirl.create(:work_with_events, doi: "10.1371/journal.pcbi.1000204") }
  #   let(:csv) { "contents,of,a,csv,file,here" }
  #   let(:filename) { "alm_stats" }
  #   let(:mendeley) { FactoryGirl.create(:mendeley) }
  #
  #   it "should write report file" do
  #     filepath = "#{Rails.root}/data/report_#{Time.zone.now.to_date.iso8601}/#{filename}.csv"
  #     response = subject.write("#{filename}.csv", csv)
  #     expect(response).to eq (filepath)
  #   end
  #
  #   describe "merge and compress csv file" do
  #     before(:each) do
  #       subject.write("#{filename}.csv", csv)
  #     end
  #
  #     it "should zip report file" do
  #       filename = "alm_report"
  #       zip_filepath = "#{Rails.root}/public/files/#{filename}.zip"
  #       subject.write("#{filename}.csv", csv)
  #
  #       response = subject.zip_file
  #       expect(response).to eq(zip_filepath)
  #       expect(File.exist?(zip_filepath)).to be true
  #       File.delete zip_filepath
  #     end
  #
  #     it "should zip report folder" do
  #       zip_filepath = "#{Rails.root}/data/report_#{Time.zone.now.to_date.iso8601}.zip"
  #       response = subject.zip_folder
  #       expect(response).to eq(zip_filepath)
  #       expect(File.exist?(zip_filepath)).to be true
  #       File.delete zip_filepath
  #     end
  #   end
  # end

  context "error report" do
    let(:report) { FactoryGirl.create(:error_report_with_admin_user) }

    it "send email" do
      report.send_error_report
      mail = ActionMailer::Base.deliveries.last
      expect(mail.to).to eq([report.users.map(&:email).join(",")])
      expect(mail.subject).to eq("[#{ENV['SITENAME']}] Error Report")
    end

    it "generates a multipart message (plain text and html)" do
      report.send_error_report
      mail = ActionMailer::Base.deliveries.last
      expect(mail.body.parts.length).to eq(2)
      expect(mail.body.parts.map(&:content_type)).to eq(["text/plain; charset=UTF-8", "text/html; charset=UTF-8"])
    end

    it "generates proper links to the admin dashboard" do
      report.send_error_report
      mail = ActionMailer::Base.deliveries.last
      body_html = mail.body.parts.find { |p| p.content_type.match /html/ }.body.raw_source
      expect(body_html).to include("<a href=\"http://#{ENV['SERVERNAME']}/alerts\">Go to admin dashboard</a>")
    end
  end

  context "stale source report" do
    let(:source) { FactoryGirl.create(:citeulike) }
    let(:source_ids) { [source.id] }
    let(:report) { FactoryGirl.create(:stale_source_report_with_admin_user) }

    it "send email" do
      report.send_stale_source_report(source_ids)
      mail = ActionMailer::Base.deliveries.last
      expect(mail.to).to eq([report.users.map(&:email).join(",")])
      expect(mail.subject).to eq("[#{ENV['SITENAME']}] Stale Source Report")
    end

    it "generates a multipart message (plain text and html)" do
      report.send_stale_source_report(source_ids)
      mail = ActionMailer::Base.deliveries.last
      expect(mail.body.parts.length).to eq(2)
      expect(mail.body.parts.map(&:content_type)).to eq(["text/plain; charset=UTF-8", "text/html; charset=UTF-8"])
    end

    it "generates proper links to the admin dashboard" do
      report.send_stale_source_report(source_ids)
      mail = ActionMailer::Base.deliveries.last
      body_html = mail.body.parts.find { |p| p.content_type.match /html/ }.body.raw_source
      expect(body_html).to include("<a href=\"http://#{ENV['SERVERNAME']}/alerts?class=SourceNotUpdatedError\">Go to admin dashboard</a>")
    end
  end
end
