class AddMiscToSources < ActiveRecord::Migration
  def self.up
    add_column :sources, :misc, :text
  end

  def self.down
    remove_column :sources, :misc
  end
end
