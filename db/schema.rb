# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20150602022135) do

  create_table "agents", force: :cascade do |t|
    t.string   "type",        limit: 255,                                   null: false
    t.string   "name",        limit: 255,                                   null: false
    t.string   "title",       limit: 255,                                   null: false
    t.text     "description", limit: 65535
    t.string   "kind",        limit: 255,   default: "work"
    t.string   "source_id",   limit: 255,                                   null: false
    t.integer  "state",       limit: 4,     default: 0
    t.string   "state_event", limit: 255
    t.text     "config",      limit: 65535
    t.integer  "group_id",    limit: 4,                                     null: false
    t.boolean  "queueable",   limit: 1,     default: true
    t.boolean  "eventable",   limit: 1,     default: true
    t.datetime "run_at",                    default: '1970-01-01 00:00:00', null: false
    t.datetime "created_at",                                                null: false
    t.datetime "updated_at",                                                null: false
    t.datetime "cached_at",                 default: '1970-01-01 00:00:00', null: false
    t.string   "uuid",        limit: 255
  end

  create_table "api_requests", force: :cascade do |t|
    t.string   "format",        limit: 255
    t.float    "db_duration",   limit: 24
    t.float    "view_duration", limit: 24
    t.datetime "created_at"
    t.string   "api_key",       limit: 255
    t.string   "info",          limit: 255
    t.string   "source",        limit: 255
    t.text     "ids",           limit: 65535
    t.float    "duration",      limit: 24
    t.string   "uuid",          limit: 255
  end

  add_index "api_requests", ["api_key", "created_at"], name: "index_api_requests_api_key_created_at", using: :btree
  add_index "api_requests", ["api_key"], name: "index_api_requests_on_api_key", using: :btree
  add_index "api_requests", ["created_at"], name: "index_api_requests_on_created_at", using: :btree

  create_table "api_responses", force: :cascade do |t|
    t.integer  "work_id",    limit: 4
    t.integer  "agent_id",   limit: 4
    t.integer  "task_id",    limit: 4
    t.float    "duration",   limit: 24
    t.datetime "created_at"
    t.string   "status",     limit: 255
  end

  add_index "api_responses", ["created_at"], name: "index_api_responses_created_at", using: :btree

  create_table "changes", force: :cascade do |t|
    t.integer  "work_id",         limit: 4
    t.integer  "source_id",       limit: 4
    t.integer  "trace_id",        limit: 4
    t.integer  "total",           limit: 4
    t.integer  "html",            limit: 4
    t.integer  "pdf",             limit: 4
    t.integer  "previous_total",  limit: 4
    t.datetime "created_at"
    t.integer  "update_interval", limit: 4
    t.boolean  "unresolved",      limit: 1, default: true
    t.boolean  "skipped",         limit: 1, default: false
  end

  add_index "changes", ["created_at"], name: "index_changes_created_at", using: :btree
  add_index "changes", ["total"], name: "index_changes_on_total", using: :btree
  add_index "changes", ["unresolved", "id"], name: "index_changes_unresolved_id", using: :btree

  create_table "data_migrations", force: :cascade do |t|
    t.string "version", limit: 255
  end

  create_table "days", force: :cascade do |t|
    t.integer  "work_id",    limit: 4,             null: false
    t.integer  "source_id",  limit: 4,             null: false
    t.integer  "event_id",   limit: 4,             null: false
    t.integer  "year",       limit: 4,             null: false
    t.integer  "month",      limit: 4,             null: false
    t.integer  "day",        limit: 4,             null: false
    t.integer  "total",      limit: 4, default: 0, null: false
    t.integer  "html",       limit: 4, default: 0, null: false
    t.integer  "pdf",        limit: 4, default: 0, null: false
    t.integer  "comments",   limit: 4, default: 0, null: false
    t.integer  "likes",      limit: 4, default: 0, null: false
    t.datetime "created_at",                       null: false
    t.datetime "updated_at",                       null: false
    t.integer  "readers",    limit: 4, default: 0, null: false
  end

  add_index "days", ["event_id", "year", "month", "day"], name: "index_days_on_event_id_and_year_and_month_and_day", using: :btree
  add_index "days", ["work_id", "source_id", "year", "month"], name: "index_days_on_work_id_and_source_id_and_year_and_month", using: :btree

  create_table "deposits", force: :cascade do |t|
    t.text     "uuid",         limit: 65535,                null: false
    t.string   "message_type", limit: 255,                  null: false
    t.text     "message",      limit: 16777215
    t.string   "source_token", limit: 255
    t.text     "callback",     limit: 65535
    t.integer  "state",        limit: 4,        default: 0
    t.string   "state_event",  limit: 255
    t.datetime "created_at",                                null: false
    t.datetime "updated_at",                                null: false
  end

  add_index "deposits", ["updated_at"], name: "index_deposits_on_updated_at", using: :btree

  create_table "events", force: :cascade do |t|
    t.integer  "work_id",      limit: 4,                                        null: false
    t.integer  "source_id",    limit: 4,                                        null: false
    t.datetime "retrieved_at",                  default: '1970-01-01 00:00:00', null: false
    t.integer  "total",        limit: 4,        default: 0,                     null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "events_url",   limit: 65535
    t.text     "extra",        limit: 16777215
    t.integer  "pdf",          limit: 4,        default: 0,                     null: false
    t.integer  "html",         limit: 4,        default: 0,                     null: false
    t.integer  "readers",      limit: 4,        default: 0,                     null: false
    t.integer  "comments",     limit: 4,        default: 0,                     null: false
    t.integer  "likes",        limit: 4,        default: 0,                     null: false
  end

  add_index "events", ["source_id", "total", "retrieved_at"], name: "index_retrieval_statuses_source_id_event_count_retr_at_desc", using: :btree
  add_index "events", ["source_id", "total"], name: "index_retrieval_statuses_source_id_event_count_desc", using: :btree
  add_index "events", ["source_id", "work_id", "total"], name: "index_retrieval_statuses_source_id_article_id_event_count_desc", using: :btree
  add_index "events", ["source_id"], name: "index_events_on_source_id", using: :btree
  add_index "events", ["source_id"], name: "index_rs_on_soure_id_queued_at_scheduled_at", using: :btree
  add_index "events", ["work_id", "source_id", "total"], name: "index_rs_on_article_id_soure_id_event_count", using: :btree
  add_index "events", ["work_id", "source_id"], name: "index_events_on_work_id_and_source_id", unique: true, using: :btree
  add_index "events", ["work_id", "total"], name: "index_events_on_work_id_and_total", using: :btree
  add_index "events", ["work_id"], name: "index_events_on_work_id", using: :btree

  create_table "filters", force: :cascade do |t|
    t.string   "type",        limit: 255,                  null: false
    t.string   "name",        limit: 255,                  null: false
    t.string   "title",       limit: 255,                  null: false
    t.text     "description", limit: 65535
    t.boolean  "active",      limit: 1,     default: true
    t.text     "config",      limit: 65535
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "groups", force: :cascade do |t|
    t.string   "name",       limit: 255, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "title",      limit: 255
  end

  create_table "months", force: :cascade do |t|
    t.integer  "work_id",    limit: 4,             null: false
    t.integer  "source_id",  limit: 4,             null: false
    t.integer  "event_id",   limit: 4,             null: false
    t.integer  "year",       limit: 4,             null: false
    t.integer  "month",      limit: 4,             null: false
    t.integer  "total",      limit: 4, default: 0, null: false
    t.integer  "html",       limit: 4, default: 0, null: false
    t.integer  "pdf",        limit: 4, default: 0, null: false
    t.integer  "comments",   limit: 4, default: 0, null: false
    t.integer  "likes",      limit: 4, default: 0, null: false
    t.datetime "created_at",                       null: false
    t.datetime "updated_at",                       null: false
    t.integer  "readers",    limit: 4, default: 0, null: false
  end

  add_index "months", ["event_id", "year", "month"], name: "index_months_on_event_id_and_year_and_month", using: :btree
  add_index "months", ["source_id", "year", "month"], name: "index_months_on_source_id_and_year_and_month", using: :btree
  add_index "months", ["work_id", "source_id", "year", "month"], name: "index_months_on_work_id_and_source_id_and_year_and_month", using: :btree

  create_table "notifications", force: :cascade do |t|
    t.integer  "source_id",    limit: 4
    t.string   "class_name",   limit: 255
    t.text     "message",      limit: 16777215
    t.text     "trace",        limit: 65535
    t.string   "target_url",   limit: 1000
    t.string   "user_agent",   limit: 255
    t.integer  "status",       limit: 4
    t.string   "content_type", limit: 255
    t.text     "details",      limit: 16777215
    t.boolean  "unresolved",   limit: 1,        default: true
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "remote_ip",    limit: 255
    t.integer  "work_id",      limit: 4
    t.integer  "level",        limit: 4,        default: 3
    t.string   "hostname",     limit: 255
    t.string   "uuid",         limit: 255
    t.integer  "agent_id",     limit: 4
  end

  add_index "notifications", ["class_name"], name: "index_notifications_on_class_name", using: :btree
  add_index "notifications", ["created_at"], name: "index_notifications_on_created_at", using: :btree
  add_index "notifications", ["level", "created_at"], name: "index_notifications_on_level_and_created_at", using: :btree
  add_index "notifications", ["source_id", "created_at"], name: "index_notifications_on_source_id_and_created_at", using: :btree
  add_index "notifications", ["source_id", "unresolved", "updated_at"], name: "index_notifications_on_source_id_and_unresolved_and_updated_at", using: :btree
  add_index "notifications", ["unresolved", "updated_at"], name: "index_notifications_on_unresolved_and_updated_at", using: :btree
  add_index "notifications", ["updated_at"], name: "index_notifications_on_updated_at", using: :btree
  add_index "notifications", ["work_id", "created_at"], name: "index_notifications_on_work_id_and_created_at", using: :btree

  create_table "publisher_options", force: :cascade do |t|
    t.integer  "publisher_id", limit: 4
    t.integer  "agent_id",     limit: 4
    t.string   "config",       limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "publisher_options", ["publisher_id", "agent_id"], name: "index_publisher_options_on_publisher_id_and_agent_id", unique: true, using: :btree

  create_table "publishers", force: :cascade do |t|
    t.string   "title",       limit: 255
    t.integer  "member_id",   limit: 4
    t.text     "prefixes",    limit: 65535
    t.text     "other_names", limit: 65535
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "cached_at",                 default: '1970-01-01 00:00:00', null: false
    t.string   "name",        limit: 255,                                   null: false
    t.string   "service",     limit: 255
  end

  add_index "publishers", ["member_id"], name: "index_publishers_on_member_id", unique: true, using: :btree

  create_table "relation_types", force: :cascade do |t|
    t.string   "name",          limit: 255,             null: false
    t.datetime "created_at",                            null: false
    t.datetime "updated_at",                            null: false
    t.string   "title",         limit: 255
    t.string   "inverse_title", limit: 255
    t.string   "inverse_name",  limit: 255
    t.integer  "level",         limit: 4,   default: 1
  end

  create_table "relations", force: :cascade do |t|
    t.integer  "work_id",          limit: 4,             null: false
    t.integer  "related_work_id",  limit: 4,             null: false
    t.integer  "source_id",        limit: 4
    t.integer  "relation_type_id", limit: 4,             null: false
    t.datetime "created_at",                             null: false
    t.datetime "updated_at",                             null: false
    t.integer  "level",            limit: 4, default: 1
  end

  add_index "relations", ["level", "work_id", "related_work_id"], name: "index_relations_on_level_work_related_work", using: :btree
  add_index "relations", ["work_id", "related_work_id"], name: "index_relationships_on_work_id_related_work_id", using: :btree

  create_table "reports", force: :cascade do |t|
    t.string   "name",        limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "title",       limit: 255
    t.text     "description", limit: 65535
    t.text     "config",      limit: 65535
    t.boolean  "private",     limit: 1,     default: true
  end

  create_table "reports_users", id: false, force: :cascade do |t|
    t.integer "report_id", limit: 4
    t.integer "user_id",   limit: 4
  end

  add_index "reports_users", ["report_id", "user_id"], name: "index_reports_users_on_report_id_and_user_id", using: :btree
  add_index "reports_users", ["user_id"], name: "index_reports_users_on_user_id", using: :btree

  create_table "reviews", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.integer  "state_id",   limit: 4
    t.text     "message",    limit: 65535
    t.integer  "input",      limit: 4
    t.integer  "output",     limit: 4
    t.boolean  "unresolved", limit: 1,     default: true
    t.datetime "started_at"
    t.datetime "ended_at"
    t.datetime "created_at"
  end

  add_index "reviews", ["name"], name: "index_reviews_on_name", using: :btree
  add_index "reviews", ["state_id"], name: "index_reviews_on_state_id", using: :btree

  create_table "sources", force: :cascade do |t|
    t.string   "name",        limit: 255,                                   null: false
    t.string   "title",       limit: 255,                                   null: false
    t.integer  "group_id",    limit: 4,                                     null: false
    t.boolean  "private",     limit: 1,     default: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "description", limit: 65535
    t.boolean  "active",      limit: 1,     default: false
    t.datetime "cached_at",                 default: '1970-01-01 00:00:00', null: false
    t.boolean  "eventable",   limit: 1,     default: false,                 null: false
  end

  add_index "sources", ["active"], name: "index_sources_on_active", using: :btree
  add_index "sources", ["name"], name: "index_sources_on_name", unique: true, using: :btree

  create_table "status", force: :cascade do |t|
    t.integer  "works_count",           limit: 4,   default: 0
    t.integer  "works_new_count",       limit: 4,   default: 0
    t.integer  "events_count",          limit: 4,   default: 0
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
  end

  add_index "status", ["created_at"], name: "index_status_created_at", using: :btree

  create_table "tasks", force: :cascade do |t|
    t.integer  "agent_id",     limit: 4,                                     null: false
    t.integer  "work_id",      limit: 4
    t.integer  "publisher_id", limit: 4
    t.text     "config",       limit: 65535
    t.datetime "queued_at"
    t.datetime "retrieved_at",               default: '1970-01-01 00:00:00', null: false
    t.datetime "scheduled_at",               default: '1970-01-01 00:00:00', null: false
    t.datetime "created_at",                                                 null: false
    t.datetime "updated_at",                                                 null: false
  end

  add_index "tasks", ["agent_id", "work_id"], name: "index_tasks_on_agent_id_and_work_id", unique: true, using: :btree
  add_index "tasks", ["agent_id"], name: "index_tasks_on_agent_id", using: :btree
  add_index "tasks", ["work_id"], name: "index_tasks_on_work_id", using: :btree

  create_table "users", force: :cascade do |t|
    t.string   "email",                  limit: 255, default: ""
    t.string   "encrypted_password",     limit: 255, default: "",     null: false
    t.string   "reset_password_token",   limit: 255
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          limit: 4,   default: 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip",     limit: 255
    t.string   "last_sign_in_ip",        limit: 255
    t.string   "password_salt",          limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "provider",               limit: 255
    t.string   "uid",                    limit: 255
    t.string   "name",                   limit: 255
    t.string   "authentication_token",   limit: 255
    t.string   "role",                   limit: 255, default: "user"
    t.integer  "publisher_id",           limit: 4
  end

  add_index "users", ["authentication_token"], name: "index_users_authentication_token", unique: true, using: :btree
  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree

  create_table "work_types", force: :cascade do |t|
    t.string   "name",       limit: 255, null: false
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
    t.string   "title",      limit: 255
    t.string   "container",  limit: 255
  end

  create_table "works", force: :cascade do |t|
    t.string   "doi",           limit: 255
    t.text     "title",         limit: 65535
    t.date     "published_on"
    t.string   "pmid",          limit: 255
    t.string   "pmcid",         limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "canonical_url", limit: 65535
    t.string   "mendeley_uuid", limit: 255
    t.integer  "year",          limit: 4,     default: 1970
    t.integer  "month",         limit: 4
    t.integer  "day",           limit: 4
    t.integer  "publisher_id",  limit: 4
    t.string   "pid_type",      limit: 255,                  null: false
    t.text     "pid",           limit: 65535,                null: false
    t.text     "csl",           limit: 65535
    t.integer  "work_type_id",  limit: 4
    t.boolean  "tracked",       limit: 1,     default: true
    t.string   "scp",           limit: 255
    t.string   "wos",           limit: 255
    t.string   "ark",           limit: 255
    t.string   "arxiv",         limit: 255
  end

  add_index "works", ["ark", "published_on", "id"], name: "index_works_on_ark_published_on_id", using: :btree
  add_index "works", ["ark"], name: "index_works_on_ark", unique: true, using: :btree
  add_index "works", ["arxiv", "published_on", "id"], name: "index_works_on_arxiv_published_on_id", using: :btree
  add_index "works", ["arxiv"], name: "index_works_on_arxiv", unique: true, using: :btree
  add_index "works", ["canonical_url", "published_on", "id"], name: "index_works_on_url_published_on_id", length: {"canonical_url"=>100, "published_on"=>nil, "id"=>nil}, using: :btree
  add_index "works", ["canonical_url"], name: "index_works_on_url", length: {"canonical_url"=>100}, using: :btree
  add_index "works", ["doi", "published_on", "id"], name: "index_articles_doi_published_on_article_id", using: :btree
  add_index "works", ["doi"], name: "index_works_on_doi", unique: true, using: :btree
  add_index "works", ["pid"], name: "index_works_on_pid", unique: true, length: {"pid"=>200}, using: :btree
  add_index "works", ["pmcid", "published_on", "id"], name: "index_works_on_pmcid_published_on_id", using: :btree
  add_index "works", ["pmcid"], name: "index_works_on_pmcid", unique: true, using: :btree
  add_index "works", ["pmid", "published_on", "id"], name: "index_works_on_pmid_published_on_id", using: :btree
  add_index "works", ["pmid"], name: "index_works_on_pmid", unique: true, using: :btree
  add_index "works", ["published_on"], name: "index_works_on_published_on", using: :btree
  add_index "works", ["publisher_id", "published_on"], name: "index_works_on_publisher_id_and_published_on", using: :btree
  add_index "works", ["scp", "published_on", "id"], name: "index_works_on_scp_published_on_id", using: :btree
  add_index "works", ["scp"], name: "index_works_on_scp", unique: true, using: :btree
  add_index "works", ["tracked", "published_on"], name: "index_works_on_tracked_published_on", using: :btree
  add_index "works", ["wos", "published_on", "id"], name: "index_works_on_wos_published_on_id", using: :btree
  add_index "works", ["wos"], name: "index_works_on_wos", unique: true, using: :btree

end
