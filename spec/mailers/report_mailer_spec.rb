require "spec_helper"

describe ReportMailer do
  describe "error report" do
    let(:report) { FactoryGirl.create(:error_report_with_admin_user) }
    let(:mail) { ReportMailer.send_error_report(report) }

    it "sends email" do
      mail.subject.should eq("[ALM] Error Report")
      mail.to.should eq([report.users.map(&:email).join(",")])
      mail.from.should eq([CONFIG[:notification_email]])
    end

    it "renders the body" do
      mail.body.encoded.should include("This is the ALM error report")
    end

    it "includes no reviews" do
      mail.body.encoded.should include("No review found.")
    end

    it "provides a link to the admin dashboard" do
      body_html = mail.body.parts.find {|p| p.content_type.match /html/}.body.raw_source
      body_html.should have_link('Go to admin dashboard', href: admin_alerts_url(:host => CONFIG[:hostname]))
    end
  end

  describe "status report" do
    let(:report) { FactoryGirl.create(:status_report_with_admin_user) }
    let(:mail) { ReportMailer.send_status_report(report) }

    it "sends email" do
      mail.subject.should eq("[ALM] Status Report")
      mail.to.should eq([report.users.map(&:email).join(",")])
      mail.from.should eq([CONFIG[:notification_email]])
    end

    it "renders the body" do
      mail.body.encoded.should include("This is the ALM status report")
    end

    it "provides a link to the admin dashboard" do
      body_html = mail.body.parts.find {|p| p.content_type.match /html/}.body.raw_source
      body_html.should have_link('Go to admin dashboard', href: root_url(:host => CONFIG[:hostname]))
    end
  end

  describe "article statistics report" do
    let(:report) { FactoryGirl.create(:article_statistics_report_with_admin_user) }
    let(:mail) { ReportMailer.send_article_statistics_report(report) }

    it "sends email" do
      mail.subject.should eq("[ALM] Article Statistics Report")
      mail.to.should eq([report.users.map(&:email).join(",")])
      mail.from.should eq([CONFIG[:notification_email]])
    end

    it "renders the body" do
      mail.body.encoded.should include("This is the ALM article statistics report")
    end

    it "provides a link to the admin dashboard" do
      body_html = mail.body.parts.find {|p| p.content_type.match /html/}.body.raw_source
      body_html.should have_link('Go to admin dashboard', href: root_url(:host => CONFIG[:hostname]))
    end
  end

  describe "disabled source report" do
    let(:report) { FactoryGirl.create(:disabled_source_report_with_admin_user) }
    let(:source) { FactoryGirl.create(:source) }
    let(:mail) { ReportMailer.send_disabled_source_report(report, source.id) }

    it "sends email" do
      mail.subject.should eq("[ALM] Disabled Source Report")
      mail.to.should eq([report.users.map(&:email).join(",")])
      mail.from.should eq([CONFIG[:notification_email]])
    end

    it "renders the body" do
      mail.body.encoded.should include("The following source has been disabled")
    end

    it "provides a link to the admin dashboard" do
      body_html = mail.body.parts.find {|p| p.content_type.match /html/}.body.raw_source
      body_html.should have_link('Go to admin dashboard', href: admin_source_url(source.name, :host => CONFIG[:hostname]))
    end
  end
end
