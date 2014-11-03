# encoding: UTF-8

namespace :couchdb do
  namespace :histories do
    desc "delete CouchDB history documents"
    task :delete => :environment do
      options = { start_date: ENV['START_DATE'],
                  end_date: ENV['END_DATE'] }
      number = RetrievalHistory.delete_many_documents(options)
      if number > 0
        puts "Deleting #{number} CouchDB history documents in the background..."
      else
        puts "No CouchDB history documents to delete."
      end
    end
  end
end
