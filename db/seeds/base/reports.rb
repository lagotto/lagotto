# Load reports
error_report = Report.where(name: 'error_report').first_or_create(
                :title => 'Error Report',
                :description => 'Reports error summary',
                :interval => 1.day,
                :private => true)

stale_source_report = Report.where(name: 'stale_source_report').first_or_create(
                :title => 'Stale Source Report',
                :description => 'Reports when a source has not been updated',
                :interval => 1.day,
                :private => true)

status_report = Report.where(name: 'status_report').first_or_create(
                :title => 'Status Report',
                :description => 'Reports application status',
                :interval => 1.week,
                :private => true)

work_statistics_report = Report.where(name: 'work_statistics_report').first_or_create(
                :title => 'Work Statistics Report',
                :description => 'Generates CSV file with event summaries for all works',
                :interval => 1.month,
                :private => false)

fatal_error_report = Report.where(name: 'fatal_error_report').first_or_create(
                :title => 'Fatal Error Report',
                :description => 'Reports when a fatal error has occured',
                :interval => 0,
                :private => true)

missing_workers_report = Report.where(name: 'missing_workers_report').first_or_create(
                :title => 'Missing Workers Report',
                :description => 'Reports when workers are not running',
                :interval => 0,
                :private => true)
