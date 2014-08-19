# encoding: UTF-8

class ReportMailer < ActionMailer::Base
  default :from => CONFIG[:notification_email]

  def send_error_report(report)
    return if report.users.empty?

    @reviews = Review.daily_report
    mail(to: report.users.map(&:email).join(","), subject: "[ALM] Error Report")
  end

  def send_fatal_error_report(report)
    return if report.users.empty?

    @source = Source.find(source_id)
    mail(to: report.users.map(&:email).join(","), subject: "[ALM] Fatal Error Report")
  end

  def send_status_report(report)
    return if report.users.empty?

    @status = Status.new

    mail(to: report.users.map(&:email).join(","), subject: "[ALM] Status Report")
  end

  def send_article_statistics_report(report)
    return if report.users.empty?

    @articles_count = Article.count

    mail(to: CONFIG[:notification_email],
         bcc: report.users.map(&:email).join(","),
         subject: "[ALM] Article Statistics Report")
  end

  def send_stale_source_report(report, source_ids)
    return if report.users.empty?

    @sources = Source.find(source_ids)
    mail(to: report.users.map(&:email).join(","), subject: "[ALM] Stale Source Report")
  end

  def send_missing_workers_report(report)
    return if report.users.empty?

    @workers_count = Worker.count

    mail(to: report.users.map(&:email).join(","), subject: "[ALM] Missing Workers Report")
  end
end
