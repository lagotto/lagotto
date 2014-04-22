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
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20140422221618) do

  create_table "alerts", :force => true do |t|
    t.integer  "source_id"
    t.string   "class_name"
    t.text     "message"
    t.text     "trace"
    t.string   "target_url",   :limit => 1000
    t.string   "user_agent"
    t.integer  "status"
    t.string   "content_type"
    t.text     "details"
    t.boolean  "unresolved",                   :default => true
    t.datetime "created_at",                                     :null => false
    t.datetime "updated_at",                                     :null => false
    t.string   "remote_ip"
    t.integer  "article_id"
    t.boolean  "error",                        :default => true
  end

  add_index "alerts", ["source_id", "unresolved", "updated_at"], :name => "index_error_messages_on_source_id_and_unresolved_and_updated_at"
  add_index "alerts", ["unresolved", "updated_at"], :name => "index_error_messages_on_unresolved_and_updated_at"
  add_index "alerts", ["updated_at"], :name => "index_error_messages_on_updated_at"

  create_table "api_requests", :force => true do |t|
    t.string   "format"
    t.float    "db_duration"
    t.float    "view_duration"
    t.datetime "created_at"
    t.string   "api_key"
    t.string   "info"
    t.string   "source"
    t.text     "ids"
  end

  add_index "api_requests", ["api_key", "created_at"], :name => "index_api_requests_api_key_created_at"
  add_index "api_requests", ["api_key"], :name => "index_api_requests_on_api_key"
  add_index "api_requests", ["created_at"], :name => "index_api_requests_on_created_at"

  create_table "api_responses", :force => true do |t|
    t.integer  "article_id"
    t.integer  "source_id"
    t.integer  "retrieval_status_id"
    t.integer  "retrieval_history_id"
    t.integer  "event_count"
    t.integer  "previous_count"
    t.float    "duration"
    t.datetime "created_at"
    t.integer  "update_interval"
    t.boolean  "unresolved",           :default => true
  end

  add_index "api_responses", ["created_at"], :name => "index_api_responses_created_at"
  add_index "api_responses", ["created_at"], :name => "index_api_responses_on_created_at"
  add_index "api_responses", ["event_count"], :name => "index_api_responses_on_event_count"
  add_index "api_responses", ["unresolved", "id"], :name => "index_api_responses_unresolved_id"

  create_table "articles", :force => true do |t|
    t.string   "doi"
    t.text     "title"
    t.date     "published_on"
    t.string   "pmid"
    t.string   "pmcid"
    t.datetime "created_at",                      :null => false
    t.datetime "updated_at",                      :null => false
    t.string   "canonical_url"
    t.string   "mendeley_uuid"
    t.integer  "year",          :default => 1970
    t.integer  "month"
    t.integer  "day"
  end

  add_index "articles", ["doi", "published_on", "id"], :name => "index_articles_doi_published_on_article_id"
  add_index "articles", ["doi"], :name => "index_articles_on_doi", :unique => true

  create_table "delayed_jobs", :force => true do |t|
    t.integer  "priority",   :default => 0
    t.integer  "attempts",   :default => 0
    t.text     "handler"
    t.text     "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by"
    t.string   "queue"
    t.datetime "created_at",                :null => false
    t.datetime "updated_at",                :null => false
  end

  add_index "delayed_jobs", ["locked_at", "locked_by", "failed_at"], :name => "index_delayed_jobs_locked_at_locked_by_failed_at"
  add_index "delayed_jobs", ["priority", "run_at"], :name => "delayed_jobs_priority"
  add_index "delayed_jobs", ["queue"], :name => "index_delayed_jobs_queue"
  add_index "delayed_jobs", ["run_at", "locked_at", "locked_by", "failed_at", "priority"], :name => "index_delayed_jobs_run_at_locked_at_locked_by_failed_at_priority"

  create_table "filters", :force => true do |t|
    t.string  "type",                           :null => false
    t.string  "name",                           :null => false
    t.string  "display_name",                   :null => false
    t.text    "description"
    t.boolean "active",       :default => true
    t.text    "config"
  end

  create_table "groups", :force => true do |t|
    t.string   "name",         :null => false
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
    t.string   "display_name"
  end

  create_table "reports", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "display_name"
    t.text     "description"
    t.text     "config"
    t.boolean  "private",      :default => true
  end

  create_table "reports_users", :id => false, :force => true do |t|
    t.integer "report_id"
    t.integer "user_id"
  end

  add_index "reports_users", ["report_id", "user_id"], :name => "index_reports_users_on_report_id_and_user_id"
  add_index "reports_users", ["user_id"], :name => "index_reports_users_on_user_id"

  create_table "retrieval_histories", :force => true do |t|
    t.integer  "retrieval_status_id",                :null => false
    t.integer  "article_id",                         :null => false
    t.integer  "source_id",                          :null => false
    t.datetime "retrieved_at"
    t.string   "status"
    t.string   "msg"
    t.integer  "event_count",         :default => 0
    t.datetime "created_at",                         :null => false
    t.datetime "updated_at",                         :null => false
  end

  add_index "retrieval_histories", ["retrieval_status_id", "retrieved_at"], :name => "index_rh_on_id_and_retrieved_at"
  add_index "retrieval_histories", ["source_id", "status", "updated_at"], :name => "index_retrieval_histories_on_source_id_and_status_and_updated_at"

  create_table "retrieval_statuses", :force => true do |t|
    t.integer  "article_id",                                       :null => false
    t.integer  "source_id",                                        :null => false
    t.datetime "queued_at"
    t.datetime "retrieved_at",  :default => '1970-01-01 00:00:00', :null => false
    t.integer  "event_count",   :default => 0
    t.string   "data_rev"
    t.datetime "created_at",                                       :null => false
    t.datetime "updated_at",                                       :null => false
    t.datetime "scheduled_at"
    t.string   "events_url"
    t.string   "event_metrics"
  end

  add_index "retrieval_statuses", ["article_id", "source_id"], :name => "index_retrieval_statuses_on_article_id_and_source_id", :unique => true
  add_index "retrieval_statuses", ["source_id", "article_id", "event_count"], :name => "index_retrieval_statuses_source_id_article_id_event_count_desc"
  add_index "retrieval_statuses", ["source_id", "event_count", "retrieved_at"], :name => "index_retrieval_statuses_source_id_event_count_retr_at_desc"
  add_index "retrieval_statuses", ["source_id", "event_count"], :name => "index_retrieval_statuses_source_id_event_count_desc"

  create_table "reviews", :force => true do |t|
    t.string   "name"
    t.integer  "state_id"
    t.text     "message"
    t.integer  "input"
    t.integer  "output"
    t.boolean  "unresolved", :default => true
    t.datetime "started_at"
    t.datetime "ended_at"
    t.datetime "created_at"
  end

  add_index "reviews", ["name"], :name => "index_reviews_on_name"
  add_index "reviews", ["state_id"], :name => "index_reviews_on_state_id"

  create_table "sources", :force => true do |t|
    t.string   "type",                                            :null => false
    t.string   "name",                                            :null => false
    t.string   "display_name",                                    :null => false
    t.datetime "run_at",       :default => '1970-01-01 00:00:00', :null => false
    t.text     "config"
    t.integer  "group_id",                                        :null => false
    t.boolean  "private",      :default => false
    t.datetime "created_at",                                      :null => false
    t.datetime "updated_at",                                      :null => false
    t.text     "description"
    t.integer  "state"
    t.boolean  "queueable",    :default => true
    t.string   "state_event"
    t.datetime "cached_at",    :default => '1970-01-01 00:00:00', :null => false
  end

  add_index "sources", ["name"], :name => "index_sources_on_name", :unique => true
  add_index "sources", ["type"], :name => "index_sources_on_type", :unique => true

  create_table "users", :force => true do |t|
    t.string   "email",                  :default => "",     :null => false
    t.string   "encrypted_password",     :default => "",     :null => false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.string   "password_salt"
    t.datetime "created_at",                                 :null => false
    t.datetime "updated_at",                                 :null => false
    t.string   "username"
    t.string   "provider"
    t.string   "uid"
    t.string   "name"
    t.string   "authentication_token"
    t.string   "role",                   :default => "user"
  end

  add_index "users", ["authentication_token"], :name => "index_users_authentication_token", :unique => true
  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["reset_password_token"], :name => "index_users_on_reset_password_token", :unique => true
  add_index "users", ["username"], :name => "index_users_username", :unique => true

  create_table "workers", :force => true do |t|
    t.integer  "identifier", :null => false
    t.string   "queue",      :null => false
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

end
