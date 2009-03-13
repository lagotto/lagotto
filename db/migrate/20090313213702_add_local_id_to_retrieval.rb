class AddLocalIdToRetrieval < ActiveRecord::Migration
  def self.up
    add_column :retrievals, :local_id, :string
  end

  def self.down
    remove_column :retrievals, :local_id
  end
end
