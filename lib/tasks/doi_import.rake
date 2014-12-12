desc "Bulk-import DOIs from standard input"
task :doi_import => :environment do
  Rake::Task["db:works:load"].invoke
  Rake::Task["db:works:load"].reenable
end
