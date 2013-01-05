class AddIndexes < ActiveRecord::Migration
  def up
    add_index :articles, :published_on, :order => :desc
    add_index :retrieval_statuses, [:source_id, :event_count]
    add_index :retrieval_statuses, [:source_id, :queued_at, :scheduled_at], :name => "index_rs_on_source_id_and_queued_at_and_sceduled_at"
    add_index :retrieval_histories, [:status, :retrieved_at], :length => { :status => 2 }
    add_index :retrieval_histories, [:article_id, :retrieved_at]
  end

  def down
    remove_index :articles, :column => :published_on
    remove_index :retrieval_statuses, :column => [:source_id, :event_count]
    remove_index :retrieval_statuses, :name => "index_rs_on_source_id_and_queued_at_and_sceduled_at"
    remove_index :retrieval_histories, :column => [:status, :retrieved_at]
    remove_index :retrieval_histories, :column => [:article_id, :retrieved_at]
  end
end
