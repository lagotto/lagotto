require 'fileutils'

namespace :api do
  namespace :snapshot do
    desc 'Takes a snapshot of the events API, zips it, and uploads to Zenodo'
    task :events => [:environment, 'zenodo:requirements_check'] do
      endpoint = "/api/references"
      ApiSnapshotUtility.snapshot_later "/api/events", upload_on_finished: true
      puts "Queuing a snapshot for /api/events"
    end

    desc 'Takes a snapshot of the references API, zips it, and uploads to Zenodo'
    task :references => [:environment, 'zenodo:requirements_check'] do
      endpoint = "/api/references"
      ApiSnapshotUtility.snapshot_later endpoint, upload_on_finished: true
      puts "Queuing a snapshot for #{endpoint}"
    end

    desc 'Takes a snapshot of the works API, zips it, and uploads to Zenodo'
    task :works => [:environment, 'zenodo:requirements_check'] do
      endpoint = "/api/works"
      ApiSnapshotUtility.snapshot_later endpoint, upload_on_finished: true
      puts "Queuing a snapshot for #{endpoint}"
    end

    task :all => ['api:snapshot:works', 'api:snapshot:events', 'api:snapshot:references']
  end
end
