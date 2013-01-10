class AddDeletedColumn < ActiveRecord::Migration
  def self.up
    create_table :error_messages do |t|
      t.integer :source_id
      t.text :class_name
      t.text :message
      t.text :trace
      t.text :target_url
      t.text :user_agent
      t.integer :status
      t.string :content_type
      t.boolean :unresolved, :default => 1

      t.timestamps
    end
    
    add_index :error_messages, :source_id
    add_index :error_messages, :updated_at
    add_index :error_messages, :unresolved
  end

  def self.down
    drop_table :error_messages
  end
end
