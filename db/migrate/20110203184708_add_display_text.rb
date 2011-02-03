class AddDisplayText < ActiveRecord::Migration
  def self.up
    add_column :sources, :display_text, :string
  end

  def self.down
    remove_column :sources, :display_text, :string
  end
end
