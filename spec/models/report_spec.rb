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

  context "generate csv" do
    let!(:work) { FactoryGirl.create(:work_with_events) }

    it "should format the Lagotto data as csv" do
      response = CSV.parse(subject.to_csv)
      expect(response.length).to eq(2)
      expect(response.first).to eq(["pid_type", "pid", "publication_date", "title", "citeulike"])
      expect(response.last).to eq([work.pid_type, work.pid, work.published_on.iso8601, work.title, "50"])
    end
  end

  context "write csv to file" do

    before(:each) do
      FileUtils.rm_rf("#{Rails.root}/data/report_#{Date.today.iso8601}")
    end

    let!(:work) { FactoryGirl.create(:work_with_events, doi: "10.1371/journal.pcbi.1000204") }
    let(:csv) { subject.to_csv }
    let(:filename) { "alm_stats.csv" }
    let(:mendeley) { FactoryGirl.create(:mendeley) }

    it "should write report file" do
      filepath = "#{Rails.root}/data/report_#{Date.today.iso8601}/#{filename}"
      response = subject.write(filename, csv)
      expect(response).to eq (filepath)
    end

    describe "merge and compress csv file" do

      before(:each) do
        subject.write(filename, csv)
      end

      it "should read stats" do
        stat = { name: "alm_stats" }
        response = subject.read_stats(stat).to_s
        expect(response).to eq(csv)
      end

      it "should merge stats" do
        url = "#{ENV['COUCHDB_URL']}/_design/reports/_view/mendeley"
        stub = stub_request(:get, url).to_return(:body => File.read(fixture_path + 'mendeley_report.json'), :status => 200, :headers => { "Content-Type" => "application/json" })
        filename = "mendeley_stats.csv"
        filepath = "#{Rails.root}/data/report_#{Date.today.iso8601}/#{filename}"
        csv = mendeley.to_csv
        subject.write(filename, csv)

        response = CSV.parse(subject.merge_stats)
        expect(response.length).to eq(2)
        expect(response.first).to eq(["pid_type", "pid", "publication_date", "title", "citeulike", "mendeley_readers", "mendeley_groups"])
        expect(response.last).to eq([work.pid_type, work.pid, work.published_on.iso8601, work.title, "50", "1663", "0"])
        File.delete filepath
      end

      it "should merge stats from single report" do
        response = subject.merge_stats.to_s
        expect(response).to eq(csv)
      end

      it "should zip report file" do
        csv = subject.merge_stats
        filename = "alm_report.csv"
        zip_filepath = "#{Rails.root}/public/files/alm_report.zip"
        subject.write(filename, csv)

        response = subject.zip_file
        expect(response).to eq(zip_filepath)
        expect(File.exist?(zip_filepath)).to be true
        File.delete zip_filepath
      end

      it "should zip report folder" do
        zip_filepath = "#{Rails.root}/data/report_#{Date.today.iso8601}.zip"
        response = subject.zip_folder
        expect(response).to eq(zip_filepath)
        expect(File.exist?(zip_filepath)).to be true
        File.delete zip_filepath
      end
    end
  end

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
