class AddPublisherOptionsIndex < ActiveRecord::Migration
  def up
    add_index :publisher_options, [:publisher_id, :source_id], :unique => true
  end

  def down
    remove_index :publisher_options, [:publisher_id, :source_id]
  end
end
