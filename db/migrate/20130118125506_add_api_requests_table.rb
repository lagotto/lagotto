class AddApiRequestsTable < ActiveRecord::Migration
  def self.up
    create_table :api_requests do |t|
      t.text :path
      t.string :format
      t.float :page_duration
      t.float :db_duration
      t.float :view_duration
      t.datetime :created_at
    end

    add_index :api_requests, :created_at
  end

  def self.down
    drop_table :api_requests
  end

end
