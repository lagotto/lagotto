class AddIndexes < ActiveRecord::Migration
  def up
    add_index :articles, :published_on 
    add_index :retrieval_statuses, :article_id
    add_index :retrieval_statuses, :source_id
    add_index :retrieval_histories, :source_id
  end

  def down
    remove_index :articles, :column => :published_on 
    remove_index :retrieval_statuses, :column => :article_id 
    remove_index :retrieval_statuses, :column => :source_id 
    remove_index :retrieval_histories, :source_id
  end
end
