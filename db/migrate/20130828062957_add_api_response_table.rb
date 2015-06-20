class AddApiResponseTable < ActiveRecord::Migration
  def self.up
    create_table :api_responses do |t|
      t.integer :article_id
      t.integer :source_id
      t.integer :retrieval_status_id
      t.integer :retrieval_history_id
      t.integer :event_count
      t.integer :previous_count
      t.float :duration
      t.datetime :created_at
    end

    add_index :api_responses, :created_at
    add_index :api_responses, :event_count

    add_column :api_requests, :api_key, :string, limit: 191
    add_column :api_requests, :info, :string
    add_column :api_requests, :source, :string
    add_column :api_requests, :ids, :text
    remove_column :api_requests, :path
    remove_column :api_requests, :page_duration

    add_index :api_requests, :api_key

    add_column :error_messages, :remote_ip, :string
  end

  def self.down
    drop_table :api_responses

    remove_column :api_requests, :api_key
    remove_column :api_requests, :info
    remove_column :api_requests, :source
    remove_column :api_requests, :ids
    add_column :api_requests, :path, :text
    add_column :api_requests, :page_duration, :float

    remove_index :api_requests, name: 'index_api_requests_on_api_key'

    remove_column :error_messages, :remote_ip
  end
end
