class AddReviewsTable < ActiveRecord::Migration
  def up
    create_table :filters do |t|
      t.string   :type, null: false
      t.string   :name, null: false
      t.string   :display_name, null: false
      t.text     :description
      t.boolean  :active, default: true
      t.text     :config
    end

    create_table :reviews do |t|
      t.string :name
      t.integer :state_id
      t.text :message
      t.integer :input
      t.integer :output
      t.boolean :unresolved, default: 1
      t.datetime :started_at
      t.datetime :ended_at
      t.datetime :created_at
    end

    add_index :reviews, :name
    add_index :reviews, :state_id

    create_table :reports do |t|
      t.string :name
      t.datetime :created_at
      t.datetime :updated_at
    end

    create_table :reports_users, :id => false do |t|
      t.references :report
      t.references :user
    end
    add_index :reports_users, [:report_id, :user_id]
    add_index :reports_users, :user_id

    add_column :error_messages, :error, :boolean, default: 1
    rename_table :error_messages, :alerts

    remove_column :sources, :disable_delay
    remove_column :sources, :timeout
    remove_column :sources, :workers
    remove_column :sources, :wait_time
    remove_column :sources, :max_failed_queries
    remove_column :sources, :max_failed_query_time_interval
    remove_column :sources, :refreshable

    # Make sure no null value exist
    Source.where(disable_until: nil).update_all(disable_until: Time.zone.now)

    # Change the column to not allow null
    change_column :sources, :disable_until, :datetime, null: false, default: '1970-01-01 00:00:00'
    rename_column :sources, :disable_until, :disabled_until
  end

  def down
    drop_table :filters
    drop_table :reviews
    drop_table :reports
    drop_table :reports_users
    rename_table :alerts, :error_messages
    remove_column :error_messages, :error

    add_column :sources, :disable_delay, :integer, default: 10, null: false
    add_column :sources, :timeout, :integer, default: 30, null: false
    add_column :sources, :workers, :integer, default: 1, null: false
    add_column :sources, :wait_time, :integer, default: 300, null: false
    add_column :sources, :max_failed_queries, :integer, default: 200, null: false
    add_column :sources, :max_failed_query_time_interval, :integer, default: 86400, null: false
    add_column :sources, :refreshable, :boolean, default: true

    rename_column :sources, :disabled_until, :disable_until
    change_column :sources, :disable_until, :datetime, :null => true
  end
end
