class AddExtraScopusFields < ActiveRecord::Migration
  def self.up
    add_column :sources, :live_mode, :boolean, :default => false
    add_column :sources, :salt, :string
  end

  def self.down
    remove_column :sources, :live_mode
    remove_column :sources, :salt
  end
end
