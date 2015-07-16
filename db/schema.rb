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

ActiveRecord::Schema.define(version: 20150714070804) do

  create_table "alerts", force: :cascade do |t|
    t.integer  "source_id",    limit: 4
    t.string   "class_name",   limit: 191
    t.text     "message",      limit: 16777215
    t.text     "trace",        limit: 65535
    t.string   "target_url",   limit: 1000
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
  end

  add_index "alerts", ["class_name"], name: "index_alerts_on_class_name", using: :btree
  add_index "alerts", ["created_at"], name: "index_alerts_on_created_at", using: :btree
  add_index "alerts", ["level", "created_at"], name: "index_alerts_on_level_and_created_at", using: :btree
  add_index "alerts", ["source_id", "created_at"], name: "index_alerts_on_source_id_and_created_at", using: :btree
  add_index "alerts", ["source_id", "unresolved", "updated_at"], name: "index_alerts_on_source_id_and_unresolved_and_updated_at", using: :btree
  add_index "alerts", ["unresolved", "updated_at"], name: "index_alerts_on_unresolved_and_updated_at", using: :btree
  add_index "alerts", ["updated_at"], name: "index_alerts_on_updated_at", using: :btree
  add_index "alerts", ["work_id", "created_at"], name: "index_alerts_on_work_id_and_created_at", using: :btree

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

  add_index "api_requests", ["api_key", "created_at"], name: "index_api_requests_api_key_created_at", using: :btree
  add_index "api_requests", ["api_key"], name: "index_api_requests_on_api_key", using: :btree
  add_index "api_requests", ["created_at"], name: "index_api_requests_on_created_at", using: :btree

  create_table "api_responses", force: :cascade do |t|
    t.integer  "work_id",             limit: 4
    t.integer  "source_id",           limit: 4
    t.integer  "retrieval_status_id", limit: 4
    t.integer  "total",               limit: 4,  default: 0,     null: false
    t.integer  "previous_total",      limit: 4
    t.float    "duration",            limit: 24
    t.datetime "created_at"
    t.integer  "update_interval",     limit: 4
    t.boolean  "unresolved",                     default: true
    t.boolean  "skipped",                        default: false
    t.integer  "html",                limit: 4,  default: 0,     null: false
    t.integer  "pdf",                 limit: 4,  default: 0,     null: false
  end

  add_index "api_responses", ["created_at"], name: "index_api_responses_created_at", using: :btree
  add_index "api_responses", ["total"], name: "index_api_responses_on_total", using: :btree
  add_index "api_responses", ["unresolved", "id"], name: "index_api_responses_unresolved_id", using: :btree

  create_table "data_exports", force: :cascade do |t|
    t.string   "url",                   limit: 255
    t.string   "type",                  limit: 255
    t.datetime "started_exporting_at"
    t.datetime "finished_exporting_at"
    t.text     "data",                  limit: 65535
    t.text     "files",                 limit: 65535
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "name",                  limit: 255
  end

  create_table "data_migrations", force: :cascade do |t|
    t.string "version", limit: 191
  end

  create_table "days", force: :cascade do |t|
    t.integer  "work_id",             limit: 4,             null: false
    t.integer  "source_id",           limit: 4,             null: false
    t.integer  "retrieval_status_id", limit: 4,             null: false
    t.integer  "year",                limit: 4,             null: false
    t.integer  "month",               limit: 4,             null: false
    t.integer  "day",                 limit: 4,             null: false
    t.integer  "total",               limit: 4, default: 0, null: false
    t.integer  "html",                limit: 4, default: 0, null: false
    t.integer  "pdf",                 limit: 4, default: 0, null: false
    t.integer  "comments",            limit: 4, default: 0, null: false
    t.integer  "likes",               limit: 4, default: 0, null: false
    t.datetime "created_at",                                null: false
    t.datetime "updated_at",                                null: false
    t.integer  "readers",             limit: 4, default: 0, null: false
  end

  add_index "days", ["retrieval_status_id", "year", "month", "day"], name: "index_days_on_retrieval_status_id_and_year_and_month_and_day", using: :btree
  add_index "days", ["source_id"], name: "days_source_id_fk", using: :btree
  add_index "days", ["work_id", "source_id", "year", "month"], name: "index_days_on_work_id_and_source_id_and_year_and_month", using: :btree

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

  create_table "groups", force: :cascade do |t|
    t.string   "name",       limit: 255, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "title",      limit: 255
  end

  create_table "months", force: :cascade do |t|
    t.integer  "work_id",             limit: 4,             null: false
    t.integer  "source_id",           limit: 4,             null: false
    t.integer  "retrieval_status_id", limit: 4,             null: false
    t.integer  "year",                limit: 4,             null: false
    t.integer  "month",               limit: 4,             null: false
    t.integer  "total",               limit: 4, default: 0, null: false
    t.integer  "html",                limit: 4, default: 0, null: false
    t.integer  "pdf",                 limit: 4, default: 0, null: false
    t.integer  "comments",            limit: 4, default: 0, null: false
    t.integer  "likes",               limit: 4, default: 0, null: false
    t.datetime "created_at",                                null: false
    t.datetime "updated_at",                                null: false
    t.integer  "readers",             limit: 4, default: 0, null: false
  end

  add_index "months", ["retrieval_status_id", "year", "month"], name: "index_months_on_retrieval_status_id_and_year_and_month", using: :btree
  add_index "months", ["source_id", "year", "month"], name: "index_months_on_source_id_and_year_and_month", using: :btree
  add_index "months", ["work_id", "source_id", "year", "month"], name: "index_months_on_work_id_and_source_id_and_year_and_month", using: :btree

  create_table "publisher_options", force: :cascade do |t|
    t.integer  "publisher_id", limit: 4
    t.integer  "source_id",    limit: 4
    t.string   "config",       limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "publisher_options", ["publisher_id", "source_id"], name: "index_publisher_options_on_publisher_id_and_source_id", unique: true, using: :btree
  add_index "publisher_options", ["source_id"], name: "publisher_options_source_id_fk", using: :btree

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
    t.string   "symbol",      limit: 255
    t.text     "url",         limit: 65535
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
  add_index "relations", ["related_work_id"], name: "relations_related_work_id_fk", using: :btree
  add_index "relations", ["relation_type_id"], name: "relations_relation_type_id_fk", using: :btree
  add_index "relations", ["source_id"], name: "relations_source_id_fk", using: :btree
  add_index "relations", ["work_id", "related_work_id"], name: "index_relationships_on_work_id_related_work_id", using: :btree

  create_table "report_write_logs", force: :cascade do |t|
    t.string   "filepath",    limit: 255
    t.string   "report_type", limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

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

  add_index "reports_users", ["report_id", "user_id"], name: "index_reports_users_on_report_id_and_user_id", using: :btree
  add_index "reports_users", ["user_id"], name: "index_reports_users_on_user_id", using: :btree

  create_table "retrieval_statuses", force: :cascade do |t|
    t.integer  "work_id",      limit: 4,                                        null: false
    t.integer  "source_id",    limit: 4,                                        null: false
    t.datetime "queued_at"
    t.datetime "retrieved_at",                  default: '1970-01-01 00:00:00', null: false
    t.integer  "total",        limit: 4,        default: 0,                     null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "scheduled_at",                  default: '1970-01-01 00:00:00', null: false
    t.text     "events_url",   limit: 65535
    t.text     "extra",        limit: 16777215
    t.integer  "pdf",          limit: 4,        default: 0,                     null: false
    t.integer  "html",         limit: 4,        default: 0,                     null: false
    t.integer  "readers",      limit: 4,        default: 0,                     null: false
    t.integer  "comments",     limit: 4,        default: 0,                     null: false
    t.integer  "likes",        limit: 4,        default: 0,                     null: false
  end

  add_index "retrieval_statuses", ["source_id", "queued_at", "scheduled_at"], name: "index_rs_on_soure_id_queued_at_scheduled_at", using: :btree
  add_index "retrieval_statuses", ["source_id", "total", "retrieved_at"], name: "index_retrieval_statuses_source_id_event_count_retr_at_desc", using: :btree
  add_index "retrieval_statuses", ["source_id", "total"], name: "index_retrieval_statuses_source_id_event_count_desc", using: :btree
  add_index "retrieval_statuses", ["source_id", "work_id", "total"], name: "index_retrieval_statuses_source_id_article_id_event_count_desc", using: :btree
  add_index "retrieval_statuses", ["source_id"], name: "index_retrieval_statuses_on_source_id", using: :btree
  add_index "retrieval_statuses", ["work_id", "source_id", "total"], name: "index_rs_on_article_id_soure_id_event_count", using: :btree
  add_index "retrieval_statuses", ["work_id", "source_id"], name: "index_retrieval_statuses_on_work_id_and_source_id", unique: true, using: :btree
  add_index "retrieval_statuses", ["work_id", "total"], name: "index_retrieval_statuses_on_work_id_and_total", using: :btree
  add_index "retrieval_statuses", ["work_id"], name: "index_retrieval_statuses_on_work_id", using: :btree

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

  add_index "reviews", ["name"], name: "index_reviews_on_name", using: :btree
  add_index "reviews", ["state_id"], name: "index_reviews_on_state_id", using: :btree

  create_table "sources", force: :cascade do |t|
    t.string   "type",        limit: 191
    t.string   "name",        limit: 191
    t.string   "title",       limit: 255,                                   null: false
    t.datetime "run_at",                    default: '1970-01-01 00:00:00', null: false
    t.text     "config",      limit: 65535
    t.integer  "group_id",    limit: 4,                                     null: false
    t.boolean  "private",                   default: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "description", limit: 65535
    t.integer  "state",       limit: 4,     default: 0
    t.boolean  "queueable",                 default: true
    t.string   "state_event", limit: 255
    t.datetime "cached_at",                 default: '1970-01-01 00:00:00', null: false
    t.boolean  "eventable",                 default: true
  end

  add_index "sources", ["group_id"], name: "sources_group_id_fk", using: :btree
  add_index "sources", ["name"], name: "index_sources_on_name", unique: true, using: :btree
  add_index "sources", ["state"], name: "index_sources_on_state", using: :btree
  add_index "sources", ["type"], name: "index_sources_on_type", unique: true, using: :btree

  create_table "status", force: :cascade do |t|
    t.integer  "works_count",            limit: 4,   default: 0
    t.integer  "works_new_count",        limit: 4,   default: 0
    t.integer  "events_count",           limit: 4,   default: 0
    t.integer  "responses_count",        limit: 4,   default: 0
    t.integer  "requests_count",         limit: 4,   default: 0
    t.integer  "requests_average",       limit: 4,   default: 0
    t.integer  "alerts_count",           limit: 4,   default: 0
    t.integer  "sources_working_count",  limit: 4,   default: 0
    t.integer  "sources_waiting_count",  limit: 4,   default: 0
    t.integer  "sources_disabled_count", limit: 4,   default: 0
    t.integer  "db_size",                limit: 8,   default: 0
    t.string   "version",                limit: 255
    t.string   "current_version",        limit: 255
    t.datetime "created_at",                                     null: false
    t.datetime "updated_at",                                     null: false
    t.string   "uuid",                   limit: 255
  end

  add_index "status", ["created_at"], name: "index_status_created_at", using: :btree

  create_table "users", force: :cascade do |t|
    t.string   "email",                  limit: 191
    t.string   "encrypted_password",     limit: 255, default: "",     null: false
    t.string   "reset_password_token",   limit: 191
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
    t.string   "authentication_token",   limit: 191
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
    t.string   "doi",                 limit: 191
    t.text     "title",               limit: 65535
    t.date     "published_on"
    t.string   "pmid",                limit: 191
    t.string   "pmcid",               limit: 191
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "canonical_url",       limit: 65535
    t.string   "mendeley_uuid",       limit: 255
    t.integer  "year",                limit: 4,     default: 1970
    t.integer  "month",               limit: 4
    t.integer  "day",                 limit: 4
    t.integer  "publisher_id",        limit: 4
    t.string   "pid_type",            limit: 255,   default: "url", null: false
    t.text     "pid",                 limit: 65535,                 null: false
    t.text     "csl",                 limit: 65535
    t.integer  "work_type_id",        limit: 4
    t.boolean  "tracked",                           default: false
    t.string   "scp",                 limit: 191
    t.string   "wos",                 limit: 191
    t.string   "ark",                 limit: 191
    t.string   "arxiv",               limit: 191
    t.string   "registration_agency", limit: 255
    t.string   "dataone",             limit: 191
  end

  add_index "works", ["ark", "published_on", "id"], name: "index_works_on_ark_published_on_id", using: :btree
  add_index "works", ["ark"], name: "index_works_on_ark", unique: true, using: :btree
  add_index "works", ["arxiv", "published_on", "id"], name: "index_works_on_arxiv_published_on_id", using: :btree
  add_index "works", ["arxiv"], name: "index_works_on_arxiv", unique: true, using: :btree
  add_index "works", ["canonical_url", "published_on", "id"], name: "index_works_on_url_published_on_id", length: {"canonical_url"=>100, "published_on"=>nil, "id"=>nil}, using: :btree
  add_index "works", ["canonical_url"], name: "index_works_on_url", length: {"canonical_url"=>100}, using: :btree
  add_index "works", ["created_at"], name: "index_works_on_created_at", using: :btree
  add_index "works", ["dataone"], name: "index_works_on_dataone", unique: true, using: :btree
  add_index "works", ["doi", "published_on", "id"], name: "index_articles_doi_published_on_article_id", using: :btree
  add_index "works", ["doi"], name: "index_works_on_doi", unique: true, using: :btree
  add_index "works", ["pid"], name: "index_works_on_pid", unique: true, length: {"pid"=>191}, using: :btree
  add_index "works", ["pmcid", "published_on", "id"], name: "index_works_on_pmcid_published_on_id", using: :btree
  add_index "works", ["pmcid"], name: "index_works_on_pmcid", unique: true, using: :btree
  add_index "works", ["pmid", "published_on", "id"], name: "index_works_on_pmid_published_on_id", using: :btree
  add_index "works", ["pmid"], name: "index_works_on_pmid", unique: true, using: :btree
  add_index "works", ["published_on"], name: "index_works_on_published_on", using: :btree
  add_index "works", ["publisher_id", "published_on"], name: "index_works_on_publisher_id_and_published_on", using: :btree
  add_index "works", ["registration_agency"], name: "index_works_on_registration_agency", using: :btree
  add_index "works", ["scp", "published_on", "id"], name: "index_works_on_scp_published_on_id", using: :btree
  add_index "works", ["scp"], name: "index_works_on_scp", unique: true, using: :btree
  add_index "works", ["tracked", "published_on"], name: "index_works_on_tracked_published_on", using: :btree
  add_index "works", ["work_type_id"], name: "works_work_type_id_fk", using: :btree
  add_index "works", ["wos", "published_on", "id"], name: "index_works_on_wos_published_on_id", using: :btree
  add_index "works", ["wos"], name: "index_works_on_wos", unique: true, using: :btree

  add_foreign_key "days", "retrieval_statuses", name: "days_retrieval_status_id_fk", on_delete: :cascade
  add_foreign_key "days", "sources", name: "days_source_id_fk", on_delete: :cascade
  add_foreign_key "days", "works", name: "days_work_id_fk", on_delete: :cascade
  add_foreign_key "months", "retrieval_statuses", name: "months_retrieval_status_id_fk", on_delete: :cascade
  add_foreign_key "months", "sources", name: "months_source_id_fk", on_delete: :cascade
  add_foreign_key "months", "works", name: "months_work_id_fk", on_delete: :cascade
  add_foreign_key "publisher_options", "publishers", primary_key: "member_id", name: "publisher_options_publisher_id_fk", on_delete: :cascade
  add_foreign_key "publisher_options", "sources", name: "publisher_options_source_id_fk", on_delete: :cascade
  add_foreign_key "relations", "relation_types", name: "relations_relation_type_id_fk", on_delete: :cascade
  add_foreign_key "relations", "sources", name: "relations_source_id_fk", on_delete: :cascade
  add_foreign_key "relations", "works", column: "related_work_id", name: "relations_related_work_id_fk", on_delete: :cascade
  add_foreign_key "relations", "works", name: "relations_work_id_fk", on_delete: :cascade
  add_foreign_key "reports_users", "reports", name: "reports_users_report_id_fk", on_delete: :cascade
  add_foreign_key "reports_users", "users", name: "reports_users_user_id_fk", on_delete: :cascade
  add_foreign_key "retrieval_statuses", "sources", name: "retrieval_statuses_source_id_fk", on_delete: :cascade
  add_foreign_key "retrieval_statuses", "works", name: "retrieval_statuses_work_id_fk", on_delete: :cascade
  add_foreign_key "sources", "groups", name: "sources_group_id_fk", on_delete: :cascade
  add_foreign_key "works", "work_types", name: "works_work_type_id_fk", on_delete: :cascade
end
