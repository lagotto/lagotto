# encoding: UTF-8

namespace :mailer do
  desc "Send error report"
  task :error_report => :environment do
    report = Report.where(name: "error_report").first
    report.send_error_report
    puts "Error report sent to #{report.users.count} subscriber(s)"
  end

  desc "Send status report"
  task :status_report => :environment do
    report = Report.where(name: "status_report").first
    report.send_status_report
    puts "Status report sent to #{report.users.count} subscriber(s)"
  end

  desc "Send article statistics report"
  task :article_statistics_report => :environment do
    report = Report.where(name: "article_statistics_report").first
    report.send_article_statistics_report
    puts "Article statistics report sent to #{report.users.count} subscriber(s)"
  end

  desc "Rename error report"
  task :rename_report => :environment do
    Report.where(name: "disabled_source_report").delete_all
    fatal_error_report = Report.where(name: 'fatal_error_report').first_or_create(
                :display_name => 'Fatal Error Report',
                :description => 'Reports when a fatal error has occured',
                :interval => 0,
                :private => true)
    puts "Reports updated"
  end

  desc 'Send all scheduled mails'
  task :all => [:environment, :error_report, :article_statistics_report, :status_report]
end
