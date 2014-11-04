class AddMoreRetrievalStatusIndexes < ActiveRecord::Migration
  def up
    change_column :retrieval_statuses, :scheduled_at, :datetime, :default => '1970-01-01 00:00:00', :null=>false

    add_index :retrieval_statuses, ["article_id", "source_id", "event_count"], name: "index_rs_on_article_id_soure_id_event_count"
    add_index :retrieval_statuses, ["source_id", "queued_at", "scheduled_at"], name: "index_rs_on_soure_id_queued_at_scheduled_at"
  end

  def down
    change_column :retrieval_statuses, :scheduled_at, :datetime

    remove_index :retrieval_statuses, name: "index_rs_on_article_id_soure_id_event_count"
    remove_index :retrieval_statuses, name: "index_rs_on_soure_id_queued_at_scheduled_at"
  end
end
