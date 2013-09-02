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
  end

  def down
    drop_table :filters
    drop_table :reviews
    drop_table :reports
    drop_table :reports_users
    rename_table :alerts, :error_messages
    remove_column :error_messages, :error
  end
end
