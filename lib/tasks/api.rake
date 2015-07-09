require 'fileutils'

namespace :api do
  namespace :snapshot do
    task :events => :environment do
      endpoint = "/api/references"
      ApiSnapshotUtility.snapshot_later "/api/events", upload_on_finished: true
      puts "Queuing a snapshot for /api/events"
    end

    task :references => :environment do
      endpoint = "/api/references"
      ApiSnapshotUtility.snapshot_later endpoint, upload_on_finished: true
      puts "Queuing a snapshot for #{endpoint}"
    end

    task :works => :environment do
      endpoint = "/api/works"
      ApiSnapshotUtility.snapshot_later endpoint, upload_on_finished: true
      puts "Queuing a snapshot for #{endpoint}"
    end

    task :all => ['api:snapshot:works', 'api:snapshot:events', 'api:snapshot:references']
  end
end
