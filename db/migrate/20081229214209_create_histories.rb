class CreateHistories < ActiveRecord::Migration
  def self.up
    create_table :histories do |t|
      t.integer :retrieval_id, :null => false
      t.integer :year, :null => false
      t.integer :month, :null => false
      t.integer :citations_count, :default => 0
      t.timestamps
    end
    add_index :histories, [:retrieval_id, :year, :month], :unique => true
  end

  def self.down
    drop_table :histories
    remove_index :histories, [:retrieval_id, :year, :month]
  end
end
