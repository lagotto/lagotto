require "spec_helper"

describe ReportMailer do
  describe "daily report" do
    let(:report) { FactoryGirl.create(:report_with_admin_user) }
    let(:mail) { ReportMailer.send_daily_report(report) }

    it "sends email" do
      mail.subject.should eq("[ALM] Daily Report")
      mail.to.should eq([report.users.map(&:email).join(",")])
      mail.from.should eq([APP_CONFIG['notification_email']])
    end

    it "renders the body" do
      mail.body.encoded.should include("This is the daily ALM report")
    end

    it "includes no reviews" do
      mail.body.encoded.should include("No review found.")
    end

    # context "contains reviews" do
    #   before(:each) do
    #     @review = FactoryGirl.create(:review)
    #   end

    #   it "includes message" do
    #     mail.body.encoded.should include(@review.message)
    #   end
    # end
  end
end
