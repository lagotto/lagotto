# encoding: UTF-8
# Load reports

error_report = Report.find_or_create_by_name(
                :name => 'error_report',
                :display_name => 'Error Report',
                :description => 'Reports error summary',
                :interval => 1.day,
                :private => true)

stale_source_report = Report.find_or_create_by_name(
                :name => 'stale_source_report',
                :display_name => 'Stale Source Report',
                :description => 'Reports when a source has not been updated',
                :interval => 1.day,
                :private => true)

status_report = Report.find_or_create_by_name(
                :name => 'status_report',
                :display_name => 'Status Report',
                :description => 'Reports application status',
                :interval => 1.week,
                :private => true)

article_statistics_report = Report.find_or_create_by_name(
                :name => 'article_statistics_report',
                :display_name => 'Article Statistics Report',
                :description => 'Generates CSV file with ALM for all articles',
                :interval => 1.month,
                :private => false)

disabled_source_report = Report.find_or_create_by_name(
                :name => 'disabled_source_report',
                :display_name => 'Disabled Source Report',
                :description => 'Reports when a source has been disabled',
                :interval => 0,
                :private => true)

missing_workers_report = Report.find_or_create_by_name(
                :name => 'missing_workers_report',
                :display_name => 'Missing Workers Report',
                :description => 'Reports when workers are not running',
                :interval => 0,
                :private => true)
