namespace :couchdb do

  desc "Bulk-import CouchDB data"
  task :import => :environment do |_, args|
    if args.extras.empty?
      sources = Source.visible
    else
      sources = Source.visible.where("name in (?)", args.extras)
    end

    if sources.empty?
      puts "No visible source found."
      exit
    end

    sources.each do |source|
      source.import_from_couchdb
      puts "CouchDB import for source #{source.title} has been queued."
    end
  end
end
