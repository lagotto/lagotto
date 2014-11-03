class AddAlertsArticleIndex < ActiveRecord::Migration
  def up
    add_index :alerts, [:article_id, :created_at]
  end

  def down
    remove_index :alerts, [:article_id, :created_at]
  end
end
