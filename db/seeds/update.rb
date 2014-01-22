# encoding: UTF-8

# Run this for version updates
if ENV['VERSION'] == "2.11"
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

  # Changes to Facebook source configuration
  facebook = Source.find_by_name("facebook")
  facebook.update_attributes(url: "https://graph.facebook.com/fql?access_token=%{access_token}&q=select url, share_count, like_count, comment_count, click_count, total_count, comments_fbid from link_stat where url = '%{doi_as_url}'")
end