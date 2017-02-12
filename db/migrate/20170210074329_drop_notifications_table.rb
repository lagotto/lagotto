class DropNotificationsTable < ActiveRecord::Migration
  def up
    remove_foreign_key :months, name: "months_aggregations_id_fk", on_delete: :cascade
    remove_foreign_key :months, name: "months_source_id_fk", on_delete: :cascade
    remove_foreign_key :months, name: "months_work_id_fk", on_delete: :cascade
    remove_foreign_key :publisher_options, name: "publisher_options_agent_id_fk", on_delete: :cascade
    remove_foreign_key :publisher_options, name: "publisher_options_publisher_id_fk", on_delete: :cascade
    remove_foreign_key :relations, name: "relations_months_id_fk", on_delete: :cascade
    remove_foreign_key :relations, name: "relations_relation_type_id_fk", on_delete: :cascade
    remove_foreign_key :relations, name: "relations_source_id_fk", on_delete: :cascade
    remove_foreign_key :relations, name: "relations_related_work_id_fk", on_delete: :cascade
    remove_foreign_key :relations, name: "relations_work_id_fk", on_delete: :cascade
    remove_foreign_key :reports_users, name: "reports_users_report_id_fk", on_delete: :cascade
    remove_foreign_key :reports_users, name: "reports_users_user_id_fk", on_delete: :cascade
    remove_foreign_key :results, name: "aggregations_source_id_fk", on_delete: :cascade
    remove_foreign_key :results, name: "aggregations_work_id_fk", on_delete: :cascade
    remove_foreign_key :sources, name: "sources_group_id_fk", on_delete: :cascade
    remove_foreign_key :works, name: "works_work_type_id_fk", on_delete: :cascade

    drop_table :notifications
    drop_table :api_requests
    drop_table :api_responses
    drop_table :agents
    drop_table :filters
    drop_table :status
    drop_table :changes
    drop_table :contributions
    drop_table :contributor_roles
    drop_table :contributors
    drop_table :data_exports
    drop_table :file_write_logs
    drop_table :months
    drop_table :groups
    drop_table :prefixes
    drop_table :publisher_options
    drop_table :publishers
    drop_table :registration_agencies
    drop_table :relation_types
    drop_table :relations
    drop_table :reports
    drop_table :reports_users
    drop_table :results
    drop_table :reviews
    drop_table :users
    drop_table :work_types

    change_column :sources, :group_id, :string, limit: 191, null: true
    change_column :works, :publisher_id, :string, limit: 191
    change_column :works, :resource_type_id, :string, limit: 191
    change_column :works, :registration_agency_id, :string, limit: 191
    change_column :deposits, :message_action, :string, limit: 191, default: "add"
    remove_column :works, :mendeley_uuid
    remove_column :works, :registration_agency
    remove_column :works, :work_type_id
    add_column :works, :resource_type, :string, limit: 191
    add_column :works, :deposited_at, :datetime, default: '1970-01-01 00:00:00', null: false
    add_column :works, :schema, :string, limit: 191
    add_column :works, :schema_version, :string, limit: 191
    add_column :works, :xml, :blob, limit: 10.megabyte
  end

  def down
    create_table "notifications", force: :cascade do |t|
      t.integer  "source_id",    limit: 4
      t.string   "class_name",   limit: 191
      t.text     "message",      limit: 16777215
      t.text     "trace",        limit: 65535
      t.text     "target_url",   limit: 65535
      t.string   "user_agent",   limit: 255
      t.integer  "status",       limit: 4
      t.string   "content_type", limit: 255
      t.text     "details",      limit: 16777215
      t.boolean  "unresolved",                    default: true
      t.datetime "created_at"
      t.datetime "updated_at"
      t.string   "remote_ip",    limit: 255
      t.integer  "work_id",      limit: 4
      t.integer  "level",        limit: 4,        default: 3
      t.string   "hostname",     limit: 255
      t.string   "uuid",         limit: 255
      t.integer  "deposit_id",   limit: 4
      t.integer  "agent_id",     limit: 4
    end

    add_index "notifications", ["class_name"], name: "index_notifications_on_class_name"
    add_index "notifications", ["created_at"], name: "index_notifications_on_created_at"
    add_index "notifications", ["deposit_id"], name: "index_on_deposit_id"
    add_index "notifications", ["level", "created_at"], name: "index_notifications_on_level_and_created_at"
    add_index "notifications", ["source_id", "created_at"], name: "index_notifications_on_source_id_and_created_at"
    add_index "notifications", ["source_id", "unresolved", "updated_at"], name: "index_notifications_on_source_id_and_unresolved_and_updated_at"
    add_index "notifications", ["unresolved", "updated_at"], name: "index_notifications_on_unresolved_and_updated_at"
    add_index "notifications", ["updated_at"], name: "index_notifications_on_updated_at"
    add_index "notifications", ["work_id", "created_at"], name: "index_notifications_on_work_id_and_created_at"

    create_table "api_requests", force: :cascade do |t|
      t.string   "format",        limit: 255
      t.float    "db_duration",   limit: 24
      t.float    "view_duration", limit: 24
      t.datetime "created_at"
      t.string   "api_key",       limit: 191
      t.string   "info",          limit: 255
      t.string   "source",        limit: 255
      t.text     "ids",           limit: 65535
      t.float    "duration",      limit: 24
      t.string   "uuid",          limit: 255
    end

    add_index "api_requests", ["api_key", "created_at"], name: "index_api_requests_api_key_created_at"
    add_index "api_requests", ["api_key"], name: "index_api_requests_on_api_key"
    add_index "api_requests", ["created_at"], name: "index_api_requests_on_created_at"

    create_table "api_responses", force: :cascade do |t|
      t.integer  "work_id",    limit: 4
      t.integer  "agent_id",   limit: 4
      t.float    "duration",   limit: 24
      t.datetime "created_at"
      t.string   "status",     limit: 255
    end

    add_index "api_responses", ["created_at"], name: "index_api_responses_created_at"

    create_table "agents", force: :cascade do |t|
      t.string   "type",        limit: 191
      t.string   "name",        limit: 191
      t.string   "title",       limit: 255,                                   null: false
      t.text     "description", limit: 65535
      t.integer  "state",       limit: 4,     default: 0
      t.string   "state_event", limit: 255
      t.text     "config",      limit: 65535
      t.integer  "group_id",    limit: 4,                                     null: false
      t.datetime "run_at",                    default: '1970-01-01 00:00:00', null: false
      t.datetime "created_at",                                                null: false
      t.datetime "updated_at",                                                null: false
      t.datetime "cached_at",                 default: '1970-01-01 00:00:00', null: false
      t.string   "uuid",        limit: 255
    end

    create_table "filters", force: :cascade do |t|
      t.string   "type",        limit: 255,                  null: false
      t.string   "name",        limit: 191,                  null: false
      t.string   "title",       limit: 255,                  null: false
      t.text     "description", limit: 65535
      t.boolean  "active",                    default: true
      t.text     "config",      limit: 65535
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    create_table "status", force: :cascade do |t|
      t.integer  "works_count",           limit: 4,   default: 0
      t.integer  "works_new_count",       limit: 4,   default: 0
      t.integer  "results_count",         limit: 4,   default: 0
      t.integer  "responses_count",       limit: 4,   default: 0
      t.integer  "requests_count",        limit: 4,   default: 0
      t.integer  "requests_average",      limit: 4,   default: 0
      t.integer  "notifications_count",   limit: 4,   default: 0
      t.integer  "agents_working_count",  limit: 4,   default: 0
      t.integer  "agents_waiting_count",  limit: 4,   default: 0
      t.integer  "agents_disabled_count", limit: 4,   default: 0
      t.integer  "db_size",               limit: 8,   default: 0
      t.string   "version",               limit: 255
      t.string   "current_version",       limit: 255
      t.datetime "created_at",                                    null: false
      t.datetime "updated_at",                                    null: false
      t.string   "uuid",                  limit: 255
      t.integer  "deposits_count",        limit: 4,   default: 0
      t.integer  "relations_count",       limit: 4,   default: 0
      t.integer  "contributors_count",    limit: 4,   default: 0
      t.integer  "publishers_count",      limit: 4,   default: 0
    end

    add_index "status", ["created_at"], name: "index_status_created_at"

    create_table "changes", force: :cascade do |t|
      t.integer  "work_id",         limit: 4
      t.integer  "source_id",       limit: 4
      t.integer  "relation_id",     limit: 4
      t.integer  "total",           limit: 4
      t.integer  "html",            limit: 4
      t.integer  "pdf",             limit: 4
      t.integer  "previous_total",  limit: 4
      t.datetime "created_at"
      t.integer  "update_interval", limit: 4
      t.boolean  "unresolved",                default: true
      t.boolean  "skipped",                   default: false
    end

    add_index "changes", ["created_at"], name: "index_changes_created_at"
    add_index "changes", ["total"], name: "index_changes_on_total"
    add_index "changes", ["unresolved", "id"], name: "index_changes_unresolved_id"

    create_table "contributions", force: :cascade do |t|
      t.integer  "work_id",             limit: 4, null: false
      t.integer  "contributor_id",      limit: 4, null: false
      t.integer  "source_id",           limit: 4
      t.integer  "contributor_role_id", limit: 4
      t.datetime "created_at",                    null: false
      t.datetime "updated_at",                    null: false
      t.integer  "publisher_id",        limit: 4
      t.integer  "month_id",            limit: 4
      t.datetime "occurred_at"
    end

    add_index "contributions", ["contributor_id"], name: "index_contributions_on_contributor_id"
    add_index "contributions", ["contributor_role_id"], name: "index_contributions_on_contributor_role_id"
    add_index "contributions", ["month_id"], name: "contributions_month_id_fk"
    add_index "contributions", ["source_id"], name: "index_contributions_on_source_id"
    add_index "contributions", ["work_id", "contributor_id", "source_id"], name: "index_contributions_on_work_id_and_contributor_id_and_source_id", unique: true

    create_table "contributor_roles", force: :cascade do |t|
      t.string   "name",        limit: 255,   null: false
      t.string   "title",       limit: 255
      t.text     "description", limit: 65535
      t.datetime "created_at",                null: false
      t.datetime "updated_at",                null: false
    end

    create_table "contributors", force: :cascade do |t|
      t.string   "pid",         limit: 191,                                 null: false
      t.string   "orcid",       limit: 191
      t.string   "given_names", limit: 191
      t.string   "family_name", limit: 191
      t.datetime "cached_at",               default: '1970-01-01 00:00:00', null: false
      t.datetime "created_at",                                              null: false
      t.datetime "updated_at",                                              null: false
      t.string   "github",      limit: 191
      t.string   "literal",     limit: 191
    end

    add_index "contributors", ["github"], name: "index_contributors_on_github", unique: true
    add_index "contributors", ["orcid"], name: "index_contributors_on_orcid", unique: true
    add_index "contributors", ["pid"], name: "index_contributors_on_pid", unique: true

    create_table "data_exports", force: :cascade do |t|
      t.string   "url",                   limit: 255
      t.string   "type",                  limit: 255
      t.datetime "started_exporting_at"
      t.datetime "finished_exporting_at"
      t.text     "data",                  limit: 65535
      t.datetime "created_at"
      t.datetime "updated_at"
      t.string   "name",                  limit: 255
      t.datetime "failed_at"
    end

    create_table "file_write_logs", force: :cascade do |t|
      t.string   "filepath",   limit: 255
      t.string   "file_type",  limit: 255
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    create_table "months", force: :cascade do |t|
      t.integer  "work_id",    limit: 4,             null: false
      t.integer  "source_id",  limit: 4,             null: false
      t.integer  "year",       limit: 4,             null: false
      t.integer  "month",      limit: 4,             null: false
      t.integer  "total",      limit: 4, default: 0, null: false
      t.datetime "created_at",                       null: false
      t.datetime "updated_at",                       null: false
      t.integer  "result_id",  limit: 4
    end

    add_index "months", ["result_id"], name: "months_aggregations_id_fk"
    add_index "months", ["source_id", "year", "month"], name: "index_months_on_source_id_and_year_and_month"
    add_index "months", ["work_id", "source_id", "year", "month"], name: "index_months_on_work_id_and_source_id_and_year_and_month"
    add_index "months", ["year", "month"], name: "index_months_on_event_id_and_year_and_month"

    create_table "groups", force: :cascade do |t|
      t.string   "name",       limit: 255, null: false
      t.datetime "created_at"
      t.datetime "updated_at"
      t.string   "title",      limit: 255
    end

    create_table "prefixes", force: :cascade do |t|
      t.string   "name",                   limit: 191
      t.string   "registration_agency",    limit: 191
      t.datetime "created_at"
      t.datetime "updated_at"
      t.integer  "registration_agency_id", limit: 4,   null: false
      t.integer  "publisher_id",           limit: 4
    end

    add_index "prefixes", ["name"], name: "index_prefixes_on_name", unique: true

    create_table "publisher_options", force: :cascade do |t|
      t.integer  "publisher_id", limit: 4
      t.integer  "agent_id",     limit: 4
      t.string   "config",       limit: 255
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    add_index "publisher_options", ["agent_id"], name: "publisher_options_agent_id_fk"
    add_index "publisher_options", ["publisher_id", "agent_id"], name: "index_publisher_options_on_publisher_id_and_agent_id", unique: true

    create_table "publishers", force: :cascade do |t|
      t.string   "title",                  limit: 191
      t.text     "other_names",            limit: 65535
      t.datetime "created_at"
      t.datetime "updated_at"
      t.datetime "cached_at",                            default: '1970-01-01 00:00:00', null: false
      t.string   "name",                   limit: 191,                                   null: false
      t.string   "registration_agency",    limit: 191
      t.text     "url",                    limit: 65535
      t.boolean  "active",                               default: false
      t.datetime "checked_at",                           default: '1970-01-01 00:00:00', null: false
      t.integer  "registration_agency_id", limit: 4,                                     null: false
      t.string   "member_id",              limit: 191
    end

    add_index "publishers", ["name"], name: "index_publishers_on_name"
    add_index "publishers", ["registration_agency"], name: "index_publishers_on_registration_agency"

    create_table "registration_agencies", force: :cascade do |t|
      t.string   "name",       limit: 255
      t.string   "title",      limit: 255
      t.datetime "created_at",             null: false
      t.datetime "updated_at",             null: false
    end

    create_table "relation_types", force: :cascade do |t|
      t.string   "name",          limit: 255, null: false
      t.datetime "created_at",                null: false
      t.datetime "updated_at",                null: false
      t.string   "title",         limit: 255
      t.string   "inverse_title", limit: 255
      t.string   "inverse_name",  limit: 255
    end

    create_table "relations", force: :cascade do |t|
      t.integer  "work_id",          limit: 4,                     null: false
      t.integer  "related_work_id",  limit: 4,                     null: false
      t.integer  "source_id",        limit: 4
      t.integer  "relation_type_id", limit: 4,                     null: false
      t.datetime "created_at",                                     null: false
      t.datetime "updated_at",                                     null: false
      t.integer  "total",            limit: 4,     default: 1,     null: false
      t.datetime "occurred_at"
      t.integer  "publisher_id",     limit: 4
      t.text     "provenance_url",   limit: 65535
      t.integer  "month_id",         limit: 4
      t.boolean  "implicit",                       default: false
    end

    add_index "relations", ["month_id"], name: "relations_month_id_fk"
    add_index "relations", ["related_work_id"], name: "relations_related_work_id_fk"
    add_index "relations", ["relation_type_id"], name: "relations_relation_type_id_fk"
    add_index "relations", ["source_id"], name: "relations_source_id_fk"
    add_index "relations", ["work_id", "related_work_id", "source_id"], name: "index_relations_on_work_id_and_related_work_id_and_source_id", unique: true
    add_index "relations", ["work_id", "related_work_id"], name: "index_relationships_on_work_id_related_work_id"

    create_table "reports", force: :cascade do |t|
      t.string   "name",        limit: 255
      t.datetime "created_at"
      t.datetime "updated_at"
      t.string   "title",       limit: 255
      t.text     "description", limit: 65535
      t.text     "config",      limit: 65535
      t.boolean  "private",                   default: true
    end

    create_table "reports_users", id: false, force: :cascade do |t|
      t.integer "report_id", limit: 4
      t.integer "user_id",   limit: 4
    end

    add_index "reports_users", ["report_id", "user_id"], name: "index_reports_users_on_report_id_and_user_id"
    add_index "reports_users", ["user_id"], name: "index_reports_users_on_user_id", using: :btree

    create_table "results", force: :cascade do |t|
      t.integer  "work_id",    limit: 4,             null: false
      t.integer  "source_id",  limit: 4,             null: false
      t.integer  "total",      limit: 4, default: 0, null: false
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    add_index "results", ["source_id", "total"], name: "index_on_source_id_total"
    add_index "results", ["work_id", "source_id", "total"], name: "index_on_work_id_source_id_total"

    create_table "reviews", force: :cascade do |t|
      t.string   "name",       limit: 191
      t.integer  "state_id",   limit: 4
      t.text     "message",    limit: 65535
      t.integer  "input",      limit: 4
      t.integer  "output",     limit: 4
      t.boolean  "unresolved",               default: true
      t.datetime "started_at"
      t.datetime "ended_at"
      t.datetime "created_at"
    end

    add_index "reviews", ["name"], name: "index_reviews_on_name"
    add_index "reviews", ["state_id"], name: "index_reviews_on_state_id"

    create_table "users", force: :cascade do |t|
      t.string   "email",                limit: 191
      t.datetime "created_at"
      t.datetime "updated_at"
      t.string   "provider",             limit: 255
      t.string   "uid",                  limit: 191
      t.string   "name",                 limit: 255
      t.string   "authentication_token", limit: 191
      t.string   "role",                 limit: 255, default: "user"
      t.integer  "publisher_id",         limit: 4
    end

    add_index "users", ["authentication_token"], name: "index_users_authentication_token", unique: true, using: :btree
    add_index "users", ["uid"], name: "index_users_on_uid", unique: true, using: :btree

    create_table "work_types", force: :cascade do |t|
      t.string   "name",       limit: 255, null: false
      t.datetime "created_at",             null: false
      t.datetime "updated_at",             null: false
      t.string   "title",      limit: 255
      t.string   "container",  limit: 255
    end

    change_column :sources, :group_id, :integer, null: true
    change_column :works, :publisher_id, :integer
    change_column :works, :resource_type_id, :integer
    change_column :works, :registration_agency_id, :integer
    change_column :deposits, :message_action, :string, limit: 255, default: "create"
    add_column :works, :mendeley_uuid, :string, limit: 255
    add_column :works, :registration_agency, :string, limit: 255
    add_column :works, :work_type_id, :integer, limit: 4
    remove_column :works, :resource_type
    remove_column :works, :deposited_at
    remove_column :works, :schema
    remove_column :works, :schema_version
    remove_column :works, :xml

    add_foreign_key "months", "results", name: "months_aggregations_id_fk", on_delete: :cascade
    add_foreign_key "months", "sources", name: "months_source_id_fk", on_delete: :cascade
    add_foreign_key "months", "works", name: "months_work_id_fk", on_delete: :cascade
    add_foreign_key "publisher_options", "agents", name: "publisher_options_agent_id_fk", on_delete: :cascade
    add_foreign_key "publisher_options", "publishers", name: "publisher_options_publisher_id_fk", on_delete: :cascade
    add_foreign_key "relations", "months", name: "relations_months_id_fk", on_delete: :cascade
    add_foreign_key "relations", "relation_types", name: "relations_relation_type_id_fk", on_delete: :cascade
    add_foreign_key "relations", "sources", name: "relations_source_id_fk", on_delete: :cascade
    add_foreign_key "relations", "works", column: "related_work_id", name: "relations_related_work_id_fk", on_delete: :cascade
    add_foreign_key "relations", "works", name: "relations_work_id_fk", on_delete: :cascade
    add_foreign_key "reports_users", "reports", name: "reports_users_report_id_fk", on_delete: :cascade
    add_foreign_key "reports_users", "users", name: "reports_users_user_id_fk", on_delete: :cascade
    add_foreign_key "results", "sources", name: "aggregations_source_id_fk", on_delete: :cascade
    add_foreign_key "results", "works", name: "aggregations_work_id_fk", on_delete: :cascade
    add_foreign_key "sources", "groups", name: "sources_group_id_fk", on_delete: :cascade
    add_foreign_key "works", "work_types", name: "works_work_type_id_fk", on_delete: :cascade
  end
end
