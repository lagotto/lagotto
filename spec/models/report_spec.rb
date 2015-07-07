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
