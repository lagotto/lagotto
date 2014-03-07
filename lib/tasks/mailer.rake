# encoding: UTF-8

# $HeadURL$
# $Id$
#
# Copyright (c) 2009-2012 by Public Library of Science, a non-profit corporation
# http://www.plos.org/
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

namespace :mailer do

  desc "Send error report"
  task :error_report => :environment do
    report = Report.where(:name => "error_report").first
    report.send_error_report
    puts "Error report sent to #{report.users.count} subscriber(s)"
  end

  desc "Send status report"
  task :status_report => :environment do
    report = Report.where(:name => "status_report").first
    report.send_status_report
    puts "Status report sent to #{report.users.count} subscriber(s)"
  end

  desc "Send article statistics report"
  task :article_statistics_report => :environment do
    report = Report.where(:name => "article_statistics_report").first
    report.send_article_statistics_report
    puts "Article statistics report sent to #{report.users.count} subscriber(s)"
  end

  desc "Send stale source report"
  task :stale_source_report => :environment do
    report = Report.where(:name => "stale_source_report").first
    report.send_stale_source_report
    puts "Stale source report sent to #{report.users.count} subscriber(s)"
  end

  desc 'Send all scheduled mails'
  task :all => [:environment, :error_report, :article_statistics_report, :status_report, :stale_source_report]
end