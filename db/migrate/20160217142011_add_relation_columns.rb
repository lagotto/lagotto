class AddRelationColumns < ActiveRecord::Migration
  def change
    add_column :relations, :total, :integer, default: 1, null: false
    add_column :relations, :occurred_at, :datetime
    add_column :relations, :publisher_id, :integer
  end
end
