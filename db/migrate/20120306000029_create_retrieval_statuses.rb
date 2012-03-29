class CreateRetrievalStatuses < ActiveRecord::Migration
  def change
    create_table :retrieval_statuses do |t|
      t.integer  :article_id, :null => false                                      # article id (from articles table)
      t.integer  :source_id, :null => false                                       # source id (from sources table)
      t.datetime :queued_at                                                       # when the article source job was queued
      t.datetime :retrieved_at, :default => '1970-01-01 00:00:00', :null => false # when data was retrieved for the given article for the given source
      t.string   :local_id                                                        # source specific id for the article, (only save this information when the information can be used later)
      t.integer  :event_count                                                     # event count
      t.string   :data_rev                                                        # rev value from couchdb

      t.timestamps
    end

    add_index :retrieval_statuses, [:article_id, :source_id], :unique => true
  end
end
