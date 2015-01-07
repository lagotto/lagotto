require "rails_helper"

describe ReportMailer, :type => :mailer do
  describe "error report" do
    let(:report) { FactoryGirl.create(:error_report_with_admin_user) }
    let(:mail) { ReportMailer.send_error_report(report) }

    it "sends email" do
      expect(mail.subject).to eq("[#{ENV['SITENAME']}] Error Report")
      expect(mail.to).to eq([report.users.map(&:email).join(",")])
      expect(mail.from).to eq([ENV['ADMIN_EMAIL']])
    end

    it "renders the body" do
      expect(mail.body.encoded).to include("This is the Lagotto error report")
    end

    it "includes no reviews" do
      expect(mail.body.encoded).to include("No review found.")
    end

    it "provides a link to the admin dashboard" do
      body_html = mail.body.parts.find { |p| p.content_type.match /html/ }.body.raw_source
      expect(body_html).to have_link('Go to admin dashboard', href: alerts_url(host: ENV['SERVERNAME']))
    end
  end

  describe "status report" do
    let(:report) { FactoryGirl.create(:status_report_with_admin_user) }
    let(:mail) { ReportMailer.send_status_report(report) }

    it "sends email" do
      expect(mail.subject).to eq("[#{ENV['SITENAME']}] Status Report")
      expect(mail.to).to eq([report.users.map(&:email).join(",")])
      expect(mail.from).to eq([ENV['ADMIN_EMAIL']])
    end

    it "renders the body" do
      expect(mail.body.encoded).to include("This is the Lagotto status report")
    end

    it "provides a link to the admin dashboard" do
      body_html = mail.body.parts.find { |p| p.content_type.match /html/ }.body.raw_source
      expect(body_html).to have_link('Go to admin dashboard', href: status_url(host: ENV['SERVERNAME']))
    end
  end

  describe "work statistics report" do
    let(:report) { FactoryGirl.create(:work_statistics_report_with_admin_user) }
    let(:mail) { ReportMailer.send_work_statistics_report(report) }

    it "sends email" do
      expect(mail.subject).to eq("[#{ENV['SITENAME']}] Work Statistics Report")
      expect(mail.bcc).to eq([report.users.map(&:email).join(",")])
      expect(mail.to).to eq([ENV['ADMIN_EMAIL']])
      expect(mail.from).to eq([ENV['ADMIN_EMAIL']])
    end

    it "renders the body" do
      expect(mail.body.encoded).to include("This is the Lagotto work statistics report")
    end

    it "provides a link to the admin dashboard" do
      body_html = mail.body.parts.find { |p| p.content_type.match /html/ }.body.raw_source
      expect(body_html).to have_link(
        "Download report",
        href: "http://#{ENV['SERVERNAME']}/files/alm_report.zip")
    end
  end

  describe "fatal error report" do
    let(:report) { FactoryGirl.create(:fatal_error_report_with_admin_user) }
    let(:source) { FactoryGirl.create(:source) }
    let(:message) { "#{source.display_name} has exceeded maximum failed queries. Disabling the source." }
    let(:mail) { ReportMailer.send_fatal_error_report(report, message) }

    it "sends email" do
      expect(mail.subject).to eq("[#{ENV['SITENAME']}] Fatal Error Report")
      expect(mail.to).to eq([report.users.map(&:email).join(",")])
      expect(mail.from).to eq([ENV['ADMIN_EMAIL']])
    end

    it "renders the body" do
      expect(mail.body.encoded).to include("Disabling the source")
    end

    it "provides a link to the admin dashboard" do
      body_html = mail.body.parts.find { |p| p.content_type.match /html/ }.body.raw_source
      expect(body_html).to have_link('Go to admin dashboard', href: alerts_url(host: ENV['SERVERNAME'], level: "fatal"))
    end
  end

  describe "stale source report" do
    let(:report) { FactoryGirl.create(:stale_source_report_with_admin_user) }
    let(:source) { FactoryGirl.create(:citeulike) }
    let(:source_ids) { [source.id] }
    let(:mail) { ReportMailer.send_stale_source_report(report, source_ids) }

    it "sends email" do
      expect(mail.subject).to eq("[#{ENV['SITENAME']}] Stale Source Report")
      expect(mail.to).to eq([report.users.map(&:email).join(",")])
      expect(mail.from).to eq([ENV['ADMIN_EMAIL']])
    end

    it "renders the body" do
      expect(mail.body.encoded).to include("The following sources have not been updated for 24 hours")
    end

    it "provides a link to the admin dashboard" do
      body_html = mail.body.parts.find { |p| p.content_type.match /html/ }.body.raw_source
      expect(body_html).to have_link('Go to admin dashboard', href: alerts_url(host: ENV['SERVERNAME'], :class => "SourceNotUpdatedError"))
    end
  end
end
