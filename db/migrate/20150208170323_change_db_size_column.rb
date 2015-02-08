class ChangeDbSizeColumn < ActiveRecord::Migration
  def up
    change_column :status, :db_size, :integer, limit: 8
  end

  def down
    change_column :status, :db_size, :integer, limit: 4
  end
end
