class AddCheckedAtColumn < ActiveRecord::Migration
  def change
    add_column :publishers, :checked_at, :datetime, default: '1970-01-01 00:00:00', null: false
  end
end
