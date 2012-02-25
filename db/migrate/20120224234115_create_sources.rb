class CreateSources < ActiveRecord::Migration
  def change
    create_table :sources do |t|
      t.string   :name, :null => false
      t.string   :display_name, :null => false
      t.boolean  :active, :default => false
      t.datetime :disable_until
      t.integer  :disable_delay, :default => 10, :null => false
      t.integer  :timeout, :default => 30, :null => false
      t.integer  :batch_size, :default => 100, :null => false

      t.timestamps
    end

    add_index :sources, :name, :unique => true
  end
end
