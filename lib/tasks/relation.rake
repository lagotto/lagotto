namespace :relation do

  desc "Update month_id for all relations"
  task :set_month_id => :environment do
    count = Relation.where(implicit: false).where(month_id: nil).count
    RelationJob.perform_later
    puts "Update of month_id for #{count} relations has been queued."
  end

  task :default => :update
end
