class AddDepositId < ActiveRecord::Migration
  def up
    add_column :notifications, :deposit_id, :integer

    add_index "notifications", ["deposit_id"], name: "index_on_deposit_id"
  end

  def down
    remove_column :notifications, :deposit_id
  end
end
