class AddDepositsCountColumn < ActiveRecord::Migration
  def up
    add_column :status, :deposits_count, :integer, default: 0
  end

  def down
    remove_column :status, :deposits_count
  end
end
