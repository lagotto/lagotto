class AddDepositsCountColumn < ActiveRecord::Migration
  def up
    add_column :status, :deposits_count, :integer
  end

  def down
    remove_column :status, :deposits_count
  end
end
