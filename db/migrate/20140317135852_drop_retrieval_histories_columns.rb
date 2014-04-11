class DropRetrievalHistoriesColumns < ActiveRecord::Migration
  def up
    #drop_table :retrieval_histories
    remove_column :api_responses, :retrieval_history_id
    add_column :api_responses, :skipped, :boolean, :default => false

    remove_column :retrieval_statuses, :data_rev
    add_column :retrieval_statuses, :other, :text
  end

  def down
    # create_table "retrieval_histories", :force => true do |t|
    #   t.integer  "retrieval_status_id",                :null => false
    #   t.integer  "article_id",                         :null => false
    #   t.integer  "source_id",                          :null => false
    #   t.datetime "retrieved_at"
    #   t.string   "status"
    #   t.string   "msg"
    #   t.integer  "event_count",         :default => 0, :null => false
    #   t.datetime "created_at",                         :null => false
    #   t.datetime "updated_at",                         :null => false
    # end

    # add_index "retrieval_histories", ["retrieval_status_id", "retrieved_at"], :name => "index_rh_on_id_and_retrieved_at"
    # add_index "retrieval_histories", ["source_id", "event_count"], :name => "index_retrieval_histories_on_source_id_and_event_count"
    # add_index "retrieval_histories", ["source_id", "status", "updated_at"], :name => "index_retrieval_histories_on_source_id_and_status_and_updated_at"

    add_column :api_responses, :retrieval_history_id, :integer
    remove_column :api_responses, :skipped

    add_column :retrieval_statuses, :data_rev, :string
    remove_column :retrieval_statuses, :other
  end
end
