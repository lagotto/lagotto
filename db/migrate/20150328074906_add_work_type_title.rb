class AddWorkTypeTitle < ActiveRecord::Migration
  def up
    add_column :work_types, :title, :string
    add_column :work_types, :container, :string
  end

  def down
    remove_column :work_types, :title
    remove_column :work_types, :container
  end
end
