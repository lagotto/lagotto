# encoding: UTF-8

class ReportMailer < ActionMailer::Base
  default :from => APP_CONFIG['notification_email']

  def send_daily_error_report(report)
    mail(to: report.users.map(&:email).join(","), subject: "[ALM] Daily Error Report")
  end
end
