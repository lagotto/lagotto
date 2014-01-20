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

namespace :update do

  desc 'Update ALM data for latest release'
  task :all => :environment do |t, args|
    from_version = ENV['FROM'] || "2.10"
    to_version = VERSION

    # Update groups
    viewed = Group.find_or_create_by_name(name: "Viewed")
    viewed.update_attributes(name: "viewed", display_name: "Viewed")
    saved = Group.find_or_create_by_name(name: "Saved")
    saved.update_attributes(name: "saved", display_name: "Saved")
    discussed = Group.find_or_create_by_name(name: "Discussed")
    discussed.update_attributes(name: "discussed", display_name: "Discussed")
    cited = Group.find_or_create_by_name(name: "Cited")
    cited.update_attributes(name: "cited", display_name: "Cited")
    recommended = Group.find_or_create_by_name(name: "Recommended")
    recommended.update_attributes(name: "recommended", display_name: "Recommended")
    other = Group.find_or_create_by_name(name: "Other")
    other.update_attributes(name: "other", display_name: "Other")
    Group.destroy_all("name not in ('viewed','saved','discussed','cited','recommended','other')")

    # Update reports. This will remove all report subscriptions by users
    Report.all.each { |report| report.users.destroy_all }
    error_report = Report.find_or_create_by_name(:name => "error_report",
      :display_name => "Error Report", :description => "Reports error summary",
      :interval => 1.day, :private => true)
    status_report = Report.find_or_create_by_name(:name => "status_report",
      :display_name => "Status Report", :description => "Reports application status",
      :interval => 1.week, :private => true)
    article_statistics_report = Report.find_or_create_by_name(:name => "article_statistics_report",
      :display_name => "Article Statistics Report",
      :description => "Generates CSV file with ALM for all articles", :interval => 1.month, :private => false)
    disabled_source_report = Report.find_or_create_by_name(:name => "disabled_source_report",
      :display_name => "Disabled Source Report",
      :description => "Reports when a source has been disabled", :interval => 0, :private => true)
    Report.destroy_all("name not in ('error_report','status_report','article_statistics_report','disabled_source_report')")

    # Uninstall all sources. This will remove all unused retrieval_statuses.
    # Sources have to be installed and activated again in the admin dashboard
    Source.all.each { |source| source.uninstall }

    puts "Updated ALM data from ALM #{from_version} to ALM #{to_version}."
  end
end