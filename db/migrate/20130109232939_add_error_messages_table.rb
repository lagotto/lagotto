class AddErrorMessagesTable < ActiveRecord::Migration
  def self.up
    create_table :error_messages do |t|
      t.integer :source_id
      t.string :class_name, limit: 191
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

    add_index :error_messages, [:source_id, :unresolved, :updated_at]
    add_index :error_messages, [:unresolved, :updated_at]
    add_index :error_messages, :updated_at
  end

  def self.down
    drop_table :error_messages
  end
end
