class AddDescriptionColumn < ActiveRecord::Migration
  def up
    add_column :reports, :display_name, :string
    add_column :reports, :description, :text
    add_column :reports, :config, :text
    add_column :reports, :private, :boolean, default: 1
  end

  def down
    remove_column :reports, :display_name
    remove_column :reports, :description
    remove_column :reports, :config
    remove_column :reports, :private
  end
end