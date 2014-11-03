class ChangePublisherIdColumn < ActiveRecord::Migration
  def up
    change_column :articles, :publisher_id, :integer
  end

  def down
    change_column :articles, :publisher_id, :string
  end
end
