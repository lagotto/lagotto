require 'spec_helper'

describe Report do

  context "error report" do
    let(:report) { FactoryGirl.create(:error_report_with_admin_user) }

    it "send email" do
      report.send_error_report
      mail = ActionMailer::Base.deliveries.last
      mail.to.should == [report.users.map(&:email).join(",")]
      mail.subject.should == "[ALM] Error Report"
    end

    it "generates a multipart message (plain text and html)" do
      report.send_error_report
      mail = ActionMailer::Base.deliveries.last
      mail.body.parts.length.should == 2
      mail.body.parts.collect(&:content_type).should == ["text/plain; charset=UTF-8","text/html; charset=UTF-8"]
    end

    it "generates proper links to the admin dashboard" do
      report.send_error_report
      mail = ActionMailer::Base.deliveries.last
      body_html = mail.body.parts.find {|p| p.content_type.match /html/}.body.raw_source
      body_html.should include("<a href=\"http://#{APP_CONFIG['hostname']}/admin/alerts\">Go to admin dashboard</a>")
    end
  end
end
