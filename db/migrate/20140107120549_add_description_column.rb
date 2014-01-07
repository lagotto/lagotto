class AddDescriptionColumn < ActiveRecord::Migration
  def up
    add_column :reports, :description, :string
    add_column :reports, :interval, :string
    add_column :reports, :url, :string
    add_column :reports, :private, :boolean, default: 1
  end

  def down
    remove_column :reports, :description
    remove_column :reports, :interval
    remove_column :reports, :url
    remove_column :reports, :private
  end
end