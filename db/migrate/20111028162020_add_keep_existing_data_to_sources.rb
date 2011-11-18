class AddKeepExistingDataToSources < ActiveRecord::Migration
  def self.up
    add_column :sources, :keep_existing_data, :boolean, :default => false
  end

  def self.down
    remove_column :sources, :keep_existing_data
  end
end
