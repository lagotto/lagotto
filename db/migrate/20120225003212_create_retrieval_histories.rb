class CreateRetrievalHistories < ActiveRecord::Migration
  def change
    create_table :retrieval_histories do |t|
      t.integer  :article_id, :null => false
      t.integer  :source_id, :null => false
      t.string   :status
      t.datetime :retrieved_at
      t.text     :error_msg

      t.timestamps
    end
  end
end
