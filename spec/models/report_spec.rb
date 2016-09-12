require "rails_helper"

describe Report, :type => :model, vcr: true do
  include ActiveJob::TestHelper

  before(:each) { FactoryGirl.create(:status) }

  describe "send report to mailgun" do
    let(:report) { FactoryGirl.create(:fatal_error_report_with_admin_user) }
    let(:source) { FactoryGirl.create(:source) }
    let(:source_ids) { [source.id] }
    let(:message) { "#{source.title} has exceeded maximum failed queries. Disabling the source." }

    it "sends fatal error report" do
      report_job = report.send_fatal_error_report(message)
      _, template, options = report_job.arguments
      expect(report.send_report_to_mailgun(template, options).fetch("message", nil)).to eq("Queued. Thank you.")
    end

    it "sends error report" do
      review = FactoryGirl.create(:review)
      report = FactoryGirl.create(:error_report_with_admin_user)
      report_job = report.send_error_report
      _, template, options = report_job.arguments
      expect(report.send_report_to_mailgun(template, options).fetch("message", nil)).to eq("Queued. Thank you.")
    end

    it "sends status report" do
      report = FactoryGirl.create(:status_report_with_admin_user)
      report_job = report.send_status_report
      _, template, options = report_job.arguments
      expect(report.send_report_to_mailgun(template, options).fetch("message", nil)).to eq("Queued. Thank you.")
    end

    it "sends work statistics report" do
      report = FactoryGirl.create(:work_statistics_report_with_admin_user)
      report_job = report.send_work_statistics_report
      _, template, options = report_job.arguments
      expect(report.send_report_to_mailgun(template, options).fetch("message", nil)).to eq("Queued. Thank you.")
    end

    it "sends stale source report" do
      report = FactoryGirl.create(:stale_source_report_with_admin_user)
      report_job = report.send_stale_source_report(source_ids)
      _, template, options = report_job.arguments
      expect(report.send_report_to_mailgun(template, options).fetch("message", nil)).to eq("Queued. Thank you.")
    end
  end

  describe "send report to slack" do
    let(:report) { FactoryGirl.create(:fatal_error_report_with_admin_user) }
    let(:source) { FactoryGirl.create(:source) }
    let(:source_ids) { [source.id] }
    let(:message) { "#{source.title} has exceeded maximum failed queries. Disabling the source." }

    it "sends fatal error report" do
      report_job = report.send_fatal_error_report(message)
      _, template, options = report_job.arguments
      expect(report.send_report_to_slack(template, options)).to eq("ok")
    end

    it "sends error report" do
      review = FactoryGirl.create(:review)
      report = FactoryGirl.create(:error_report_with_admin_user)
      report_job = report.send_error_report
      _, template, options = report_job.arguments
      expect(report.send_report_to_slack(template, options)).to eq("ok")
    end

    it "sends status report" do
      report = FactoryGirl.create(:status_report_with_admin_user)
      report_job = report.send_status_report
      _, template, options = report_job.arguments
      expect(report.send_report_to_slack(template, options)).to eq("ok")
    end

    it "sends work statistics report" do
      report = FactoryGirl.create(:work_statistics_report_with_admin_user)
      report_job = report.send_work_statistics_report
      _, template, options = report_job.arguments
      expect(report.send_report_to_slack(template, options)).to eq("ok")
    end

    it "sends stale source report" do
      report = FactoryGirl.create(:stale_source_report_with_admin_user)
      report_job = report.send_stale_source_report(source_ids)
      _, template, options = report_job.arguments
      expect(report.send_report_to_slack(template, options)).to eq("ok")
    end
  end

  describe "send report to webhook" do
    let(:report) { FactoryGirl.create(:fatal_error_report_with_admin_user) }
    let(:source) { FactoryGirl.create(:source) }
    let(:source_ids) { [source.id] }
    let(:message) { "#{source.title} has exceeded maximum failed queries. Disabling the source." }

    it "sends fatal error report" do
      report_job = report.send_fatal_error_report(message)
      _, template, options = report_job.arguments
      expect(report.send_report_to_webhook(template, options)).to eq("message"=>"Post received. Thanks!")
    end

    it "sends error report" do
      review = FactoryGirl.create(:review)
      report = FactoryGirl.create(:error_report_with_admin_user)
      report_job = report.send_error_report
      _, template, options = report_job.arguments
      expect(report.send_report_to_webhook(template, options)).to eq("message"=>"Post received. Thanks!")
    end

    it "sends status report" do
      report = FactoryGirl.create(:status_report_with_admin_user)
      report_job = report.send_status_report
      _, template, options = report_job.arguments
      expect(report.send_report_to_webhook(template, options)).to eq("message"=>"Post received. Thanks!")
    end

    it "sends work statistics report" do
      report = FactoryGirl.create(:work_statistics_report_with_admin_user)
      report_job = report.send_work_statistics_report
      _, template, options = report_job.arguments
      expect(report.send_report_to_webhook(template, options)).to eq("message"=>"Post received. Thanks!")
    end

    it "sends stale source report" do
      report = FactoryGirl.create(:stale_source_report_with_admin_user)
      report_job = report.send_stale_source_report(source_ids)
      _, template, options = report_job.arguments
      expect(report.send_report_to_webhook(template, options)).to eq("message"=>"Post received. Thanks!")
    end
  end

  describe "error report" do
    let!(:review) { FactoryGirl.create(:review) }
    let(:report) { FactoryGirl.create(:error_report_with_admin_user) }

    it "creates report" do
      report_job = report.send_error_report
      _, template, options = report_job.arguments
      link = "#{ENV['SERVER_URL']}/notifications"
      expect(template).to eq("send_error_report")
      expect(options).to eq(:reviews=>[review], :title=>"Error Report", :link=>link, :level=>3)
    end
  end

  describe "status report" do
    let(:report) { FactoryGirl.create(:status_report_with_admin_user) }

    it "creates report" do
      report_job = report.send_status_report
      _, template, options = report_job.arguments
      link = "#{ENV['SERVER_URL']}/status"
      expect(template).to eq("send_status_report")
      expect(options).to eq(status: Status.first, :title=>"Status Report", :link=>link, :level=>1)
    end
  end

  describe "work statistics report" do
    let(:report) { FactoryGirl.create(:work_statistics_report_with_admin_user) }

    it "creates report" do
      report_job = report.send_work_statistics_report
      _, template, options = report_job.arguments
      link = "#{ENV['SERVER_URL']}/status"
      expect(template).to eq("send_work_statistics_report")
      expect(options).to eq(:status=>Status.first_or_create, :title=>"Work Statistics Report", :link=>link, :level=>1)
    end
  end

  describe "fatal error report" do
    let(:report) { FactoryGirl.create(:fatal_error_report_with_admin_user) }
    let(:source) { FactoryGirl.create(:source) }
    let(:message) { "#{source.title} has exceeded maximum failed queries. Disabling the source." }

    it "creates report" do
      report_job = report.send_fatal_error_report(message)
      _, template, options = report_job.arguments
      link = "#{ENV['SERVER_URL']}/notifications?level=fatal"
      expect(template).to eq("send_fatal_error_report")
      expect(options).to eq(message: message, :title=>"Fatal Error Report", :link=>link, :level=>4)
    end

    it "no report job without message" do
      message = nil
      report_job = report.send_fatal_error_report(message)
      expect(report_job).to be_nil
    end
  end

  describe "stale source report" do
    let(:report) { FactoryGirl.create(:stale_source_report_with_admin_user) }
    let(:source) { FactoryGirl.create(:source) }
    let(:source_ids) { [source.id] }

    it "creates report" do
      report_job = report.send_stale_source_report(source_ids)
      _, template, options = report_job.arguments
      link = "#{ENV['SERVER_URL']}/notifications?class=SourceNotUpdatedError"
      expect(template).to eq("send_stale_source_report")
      expect(options).to eq(:sources=>[source], :title=>"Stale Source Report", :link=>"#{ENV['SERVER_URL']}/notifications?class=SourceNotUpdatedError", :level=>2)
    end
  end
end
