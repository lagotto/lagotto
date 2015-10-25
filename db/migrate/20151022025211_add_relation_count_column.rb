class AddRelationCountColumn < ActiveRecord::Migration
  def change
    add_column :status, :relations_count, :integer, default: 0
  end
end
