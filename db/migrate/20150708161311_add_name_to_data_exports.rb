class AddNameToDataExports < ActiveRecord::Migration
  def change
    add_column :data_exports, :name, :string
  end
end
