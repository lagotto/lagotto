desc "Bulk-import DOIs from standard input"
task :doi_import => :environment do
  Rake::Task["db:articles:load"].invoke
  Rake::Task["db:articles:load"].reenable
end
