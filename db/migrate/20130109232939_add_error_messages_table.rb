class AddErrorMessagesTable < ActiveRecord::Migration
  def self.up
    create_table :alerts do |t|
      t.integer :source_id
      t.string :class_name
      t.text :message
      t.text :trace
      t.string :target_url
      t.string :user_agent
      t.integer :status
      t.string :content_type
      t.text :details
      t.boolean :unresolved, :default => 1

      t.timestamps
    end

    add_index :alerts, [:source_id, :unresolved, :updated_at]
    add_index :alerts, [:unresolved, :updated_at]
    add_index :alerts, :updated_at
  end

  def self.down
    drop_table :alerts
  end
end
