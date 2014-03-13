class CreateDelayedWorkers < ActiveRecord::Migration

  def self.up
    create_table :delayed_workers do |t|
      t.string :name
      t.timestamp :last_heartbeat_at
    end

    add_index :delayed_workers, :name, unique: true
  end

  def self.down
    drop_table :delayed_workers
  end

end