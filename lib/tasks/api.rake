require 'fileutils'

namespace :api do
  namespace :snapshot do
    task :requirements_check => ['zenodo:requirements_check'] do
      ENV['SERVERNAME'] || raise("SERVERNAME env variable must be set!")
    end

    desc 'Snapshot /api/results, zip it, and upload to Zenodo'
    task :results => [:environment, :requirements_check] do
      endpoint = "/api/results"
      ApiSnapshotUtility.snapshot_later "#{endpoint}?sort=created_at", upload_on_finished: true
      puts "Queuing a snapshot for #{endpoint}"
    end

    desc 'Snapshot /api/relations, zip it, and upload to Zenodo'
    task :relations => [:environment, :requirements_check] do
      endpoint = "/api/relations"
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
    task :all => ['api:snapshot:works', 'api:snapshot:results', 'api:snapshot:relations']
  end
end
