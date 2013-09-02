require 'spec_helper'

describe Report do

  context "daily error report" do
    let(:report) { FactoryGirl.create(:report_with_admin_user) }

    it "send email" do
      report.send_daily_error_report
      mail = ActionMailer::Base.deliveries.last
      mail.to.should == [report.users.map(&:email).join(",")]
      mail.subject.should == "[ALM] Daily Error Report"
    end

    it "generates a multipart message (plain text and html)" do
      report.send_daily_error_report
      mail = ActionMailer::Base.deliveries.last
      mail.body.parts.length.should == 2
      mail.body.parts.collect(&:content_type).should == ["text/plain; charset=UTF-8","text/html; charset=UTF-8"]
    end
  end
end
