class RenameColumnsForAgents < ActiveRecord::Migration
  def up
    rename_column :publisher_options, :source_id, :agent_id

    create_table "changes", force: true do |t|
      t.integer  "work_id"
      t.integer  "source_id"
      t.integer  "trace_id"
      t.integer  "total"
      t.integer  "html"
      t.integer  "pdf"
      t.integer  "previous_total"
      t.datetime "created_at"
      t.integer  "update_interval"
      t.boolean  "unresolved",                     default: true
      t.boolean  "skipped",                        default: false
    end

    add_index "changes", ["created_at"], name: "index_changes_created_at", using: :btree
    add_index "changes", ["total"], name: "index_changes_on_total", using: :btree
    add_index "changes", ["unresolved", "id"], name: "index_changes_unresolved_id", using: :btree

    rename_column :api_responses, :source_id, :agent_id
    rename_column :api_responses, :retrieval_status_id, :task_id
    remove_column :api_responses, :total
    remove_column :api_responses, :html
    remove_column :api_responses, :pdf
    remove_column :api_responses, :previous_total
    remove_column :api_responses, :update_interval
    remove_column :api_responses, :unresolved
    remove_column :api_responses, :skipped
    add_column    :api_responses, :status, :string
    remove_index :api_responses, name: "index_api_responses_unresolved_id"
  end

  def down
    rename_column :publisher_options, :agent_id, :source_id

    drop_table :changes

    rename_column :api_responses, :agent_id, :source_id
    rename_column :api_responses, :task_id, :retrieval_status_id
    add_column    :api_responses, :total, :integer
    add_column    :api_responses, :html, :integer
    add_column    :api_responses, :pdf, :integer
    add_column    :api_responses, :previous_total, :integer
    add_column    :api_responses, :update_interval, :integer
    add_column    :api_responses, :unresolved, :boolean
    add_column    :api_responses, :skipped, :boolean
    remove_column :api_responses, :status
    add_index     :api_responses, ["total"], name: "index_api_responses_on_total"
    add_index     :api_responses, ["unresolved", "id"], name: "index_api_responses_unresolved_id"
  end
end
