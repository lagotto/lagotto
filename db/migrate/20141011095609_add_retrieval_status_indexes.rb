class AddRetrievalStatusIndexes < ActiveRecord::Migration
  def up
    add_index :retrieval_statuses, [:article_id]
    add_index :retrieval_statuses, [:article_id, :event_count]
    add_index :retrieval_statuses, [:source_id]
  end

  def down
    remove_index :retrieval_statuses, [:article_id]
    remove_index :retrieval_statuses, [:article_id, :event_count]
    remove_index :retrieval_statuses, [:source_id]
  end
end
