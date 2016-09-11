namespace :notification do
  desc "Send fatal error report"
  task :fatal_error_report => :environment do
    if ENV['MESSAGE'].blank?
      puts "No error message found."
      exit
    end

    report = Report.where(name: 'fatal_error_report').first_or_create(
                      title: 'Fatal Error Report',
                      description: 'Reports when a fatal error has occured',
                      interval: 0,
                      private: true)
    report.send_fatal_error_report(ENV['MESSAGE'])
    puts "Fatal error report sent"
  end

  desc "Send error report"
  task :error_report => :environment do
    report = Report.where(name: "error_report").first
    report.send_error_report
    puts "Error report sent"
  end

  desc "Send status report"
  task :status_report => :environment do
    report = Report.where(name: "status_report").first
    report.send_status_report
    puts "Status report sent"
  end

  desc "Send work statistics report"
  task :work_statistics_report => :environment do
    report = Report.where(name: "work_statistics_report").first
    report.send_work_statistics_report
    puts "Work statistics report sent"
  end

  desc "Rename error report"
  task :rename_report => :environment do
    Report.where(name: "disabled_source_report").delete_all
    fatal_error_report = Report.where(name: 'fatal_error_report').first_or_create(
                :title => 'Fatal Error Report',
                :description => 'Reports when a fatal error has occured',
                :interval => 0,
                :private => true)
    puts "Reports updated"
  end

  desc 'Send all scheduled notifications'
  task :all => [:environment, :error_report, :status_report, :work_statistics_report]
end
