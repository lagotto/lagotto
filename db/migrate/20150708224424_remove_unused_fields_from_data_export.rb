class RemoveUnusedFieldsFromDataExport < ActiveRecord::Migration
  def up
    remove_column :data_exports, :size_in_kb
    remove_column :data_exports, :state
  end

  def down
    add_column :data_exports, :size_in_kb, :integer
    add_column :data_exports, :state, :string
  end
end
