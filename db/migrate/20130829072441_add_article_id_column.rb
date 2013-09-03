class AddArticleIdColumn < ActiveRecord::Migration
  def up
    add_column :alerts, :article_id, :integer
    add_column :api_responses, :update_interval, :integer
    add_column :api_responses, :unresolved, :boolean, default: 1
  end

  def down
    remove_column :alerts, :article_id
    remove_column :api_responses, :update_interval
    remove_column :api_responses, :unresolved
  end
end
