class CreateRetrievalHistories < ActiveRecord::Migration
  def change
    create_table :retrieval_histories do |t|
      t.integer  :article_id, :null => false
      t.integer  :source_id, :null => false
      t.datetime :retrieved_at
      t.string   :status
      t.string   :msg
      t.text     :error_msg
      t.integer  :event_count

      t.timestamps
    end
  end
end
