class RenameSourcesNameToType < ActiveRecord::Migration
  def self.up
    rename_column :sources, :name, :type
  end

  def self.down
    rename_column :sources, :type, :name
  end
end
