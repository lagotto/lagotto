class CreateRetrievalStatuses < ActiveRecord::Migration
  def change
    create_table :retrieval_statuses do |t|
      t.integer  :article_id, :null => false
      t.integer  :source_id, :null => false
      t.datetime :queued_at
      t.datetime :retrieved_at, :default => '1970-01-01 00:00:00', :null => false
      t.string   :data_rev

      t.timestamps
    end

    add_index :retrieval_statuses, [:article_id, :source_id], :unique => true
  end
end
