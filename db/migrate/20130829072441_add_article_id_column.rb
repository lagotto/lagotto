class AddArticleIdColumn < ActiveRecord::Migration
  def up
    add_column :error_messages, :article_id, :integer
    add_column :api_responses, :unresolved, :boolean, default: 1
  end

  def down
    remove_column :error_messages, :article_id
    remove_column :api_responses, :unresolved
  end
end
