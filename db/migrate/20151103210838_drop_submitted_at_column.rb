class DropSubmittedAtColumn < ActiveRecord::Migration
  def change
    remove_column :contributors, :submitted_at, :datetime
  end
end
