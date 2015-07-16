require 'fileutils'

namespace :api do
  namespace :snapshot do
    task :requirements_check => ['zenodo:requirements_check'] do
      ENV['SERVERNAME'] || raise("SERVERNAME env variable must be set!")
    end

    desc 'Snapshot /api/events, zip it, and upload to Zenodo'
    task :events => [:environment, :requirements_check] do
      endpoint = "/api/events"
      ApiSnapshotUtility.snapshot_later "#{endpoint}?sort=created_at", upload_on_finished: true
      puts "Queuing a snapshot for #{endpoint}"
    end

    desc 'Snapshot /api/references, zip it, and upload to Zenodo'
    task :references => [:environment, :requirements_check] do
      endpoint = "/api/references"
      ApiSnapshotUtility.snapshot_later "#{endpoint}?sort=created_at", upload_on_finished: true
      puts "Queuing a snapshot for #{endpoint}"
    end

    desc 'Snapshot /api/works, zip it, and upload to Zenodo'
    task :works => [:environment, :requirements_check] do
      endpoint = "/api/works"
      ApiSnapshotUtility.snapshot_later "#{endpoint}?sort=created_at", upload_on_finished: true
      puts "Queuing a snapshot for #{endpoint}"
    end

    desc 'Run all of the api:snapshot:* tasks in order to snapshot all available end-points'
    task :all => ['api:snapshot:works', 'api:snapshot:events', 'api:snapshot:references']
  end
end
