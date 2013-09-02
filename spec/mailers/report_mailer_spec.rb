require "spec_helper"

describe ReportMailer do
  describe "daily error report" do
    let(:report) { FactoryGirl.create(:report_with_admin_user) }
    let(:mail) { ReportMailer.send_daily_error_report(report) }

    it "sends email" do
      mail.subject.should eq("[ALM] Daily Error Report")
      mail.to.should eq([report.users.map(&:email).join(",")])
      mail.from.should eq([APP_CONFIG['notification_email']])
    end

    it "renders the body" do
      mail.body.encoded.should include("This is the daily ALM error report.")
    end
  end
end
