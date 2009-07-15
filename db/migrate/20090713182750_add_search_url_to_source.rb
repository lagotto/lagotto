class AddSearchUrlToSource < ActiveRecord::Migration
  def self.up
    add_column :sources, :searchURL, :string
  end

  def self.down
    remove_column :sources, :searchURL
  end
end