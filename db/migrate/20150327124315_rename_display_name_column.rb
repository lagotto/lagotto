class RenameDisplayNameColumn < ActiveRecord::Migration
  def up
    rename_column :filters, :display_name, :title
    rename_column :groups, :display_name, :title
    rename_column :reports, :display_name, :title
    rename_column :sources, :display_name, :title

    add_column :filters, :created_at, :datetime
    add_column :filters, :updated_at, :datetime
  end

  def down
    rename_column :filters, :title, :display_name
    rename_column :groups, :title, :display_name
    rename_column :reports, :title, :display_name
    rename_column :sources, :title, :display_name

    remove_column :filters, :created_at
    remove_column :filters, :updated_at
  end
end
