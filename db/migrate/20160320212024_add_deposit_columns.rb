class AddDepositColumns < ActiveRecord::Migration
  def change
    add_column :deposits, :work_id, :integer
    add_column :deposits, :related_work_id, :integer
    add_column :deposits, :contributor_id, :integer
  end
end
