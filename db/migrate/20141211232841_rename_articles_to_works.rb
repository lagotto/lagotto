class RenameArticlesToWorks < ActiveRecord::Migration
  def up
    rename_table :articles, :works
    rename_column :alerts, :article_id, :work_id
    rename_column :api_responses, :article_id, :work_id
    rename_column :retrieval_histories, :article_id, :work_id
    rename_column :retrieval_statuses, :article_id, :work_id
  end

  def down
    rename_table :works, :articles
    rename_column :alerts, :work_id, :article_id
    rename_column :api_responses, :work_id, :article_id
    rename_column :retrieval_histories, :work_id, :article_id
    rename_column :retrieval_statuses, :work_id, :article_id
  end
end
