# encoding: UTF-8

class ReportMailer < ActionMailer::Base
  default :from => CONFIG[:notification_email]

  def send_error_report(report)
    return if report.users.empty?

    @reviews = Review.daily_report
    mail(to: report.users.map(&:email).join(","), subject: "[Lagotto] Error Report")
  end

  def send_fatal_error_report(report, message)
    return if report.users.empty?

    @message = message
    mail(to: report.users.map(&:email).join(","), subject: "[Lagotto] Fatal Error Report")
  end

  def send_status_report(report)
    return if report.users.empty?

    @status = Status.new

    mail(to: report.users.map(&:email).join(","), subject: "[Lagotto] Status Report")
  end

  def send_article_statistics_report(report)
    return if report.users.empty?

    @articles_count = Article.count

    mail(to: CONFIG[:notification_email],
         bcc: report.users.map(&:email).join(","),
         subject: "[Lagotto] Article Statistics Report")
  end

  def send_stale_source_report(report, source_ids)
    return if report.users.empty?

    @sources = Source.find(source_ids)
    mail(to: report.users.map(&:email).join(","), subject: "[Lagotto] Stale Source Report")
  end

  def send_missing_workers_report(report)
    return if report.users.empty?

    @workers_count = Worker.count

    mail(to: report.users.map(&:email).join(","), subject: "[Lagotto] Missing Workers Report")
  end
end
