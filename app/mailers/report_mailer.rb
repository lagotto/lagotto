# encoding: UTF-8

class ReportMailer < ActionMailer::Base
  default :from => CONFIG[:notification_email]

  def send_error_report(report)
    return if report.users.empty?

    @reviews = Review.daily_report
    mail(to: report.users.map(&:email).join(","), subject: "[ALM] Error Report")
  end

  def send_status_report(report)
    return if report.users.empty?

    @articles_count = Article.count
    @articles_recent_count = Article.last_x_days(30).count
    @sources_disabled_count = Source.where("state = 1").count
    @alerts_last_day_count = Alert.total_errors(1).count

    @delayed_jobs_active_count = DelayedJob.count
    @responses_count = ApiResponse.total(1).count
    @events_count = RetrievalStatus.joins(:source).where("state > 0 AND name != 'relativemetric'").sum(:event_count)
    @requests_count = ApiRequest.where("created_at > NOW() - INTERVAL 1 DAY").count

    @users_count = User.count
    @couchdb_info = RetrievalStatus.new.get_alm_database || { "doc_count" => 0, "disk_size" => 0 }
    @mysql_info = RetrievalHistory.table_status

    mail(to: report.users.map(&:email).join(","), subject: "[ALM] Status Report")
  end

  def send_article_statistics_report(report)
    return if report.users.empty?

    @articles_count = Article.count
    @articles_recent_count = Article.last_x_days(30).count

    mail(to: report.users.map(&:email).join(","), subject: "[ALM] Article Statistics Report")
  end

  def send_disabled_source_report(report, source_id)
    return if report.users.empty?

    @source = Source.find(source_id)
    mail(to: report.users.map(&:email).join(","), subject: "[ALM] Disabled Source Report")
  end
end
