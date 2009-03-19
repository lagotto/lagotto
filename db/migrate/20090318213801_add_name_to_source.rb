class AddNameToSource < ActiveRecord::Migration
  def self.up
    add_column :sources, :name, :string
    
    Source.connection.execute("update sources set name = type")
  end

  def self.down
    remove_column :sources, :name
  end
end
