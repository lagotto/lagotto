class CreateRetrievalHistories < ActiveRecord::Migration
  def change
    create_table :retrieval_histories do |t|
      t.integer  :retrieval_status_id, :null => false  # retrieval_status id (from retrieval_statuses table)
      t.integer  :article_id, :null => false           # article id (from articles table)
      t.integer  :source_id, :null => false            # source id (from sources table)
      t.datetime :retrieved_at                         # when data was retrieved for the given article for the given source
      t.string   :status                               # status of the retrieval (success or failure)
      t.string   :msg                                  # extra information about the status of the retrieval
      t.integer  :event_count, :default => 0           # event count

      t.timestamps
    end

    add_index :retrieval_histories, [:retrieval_status_id, :retrieved_at]
  end
end
