# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of Active Record to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20110509214246) do

  create_table "articles", :force => true do |t|
    t.string   "doi",                                                :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "retrieved_at",    :default => '1970-01-01 00:00:00', :null => false
    t.string   "pub_med"
    t.string   "pub_med_central"
    t.date     "published_on"
    t.text     "title"
  end

  add_index "articles", ["doi"], :name => "index_articles_on_doi", :unique => true

  create_table "citations", :force => true do |t|
    t.integer  "retrieval_id"
    t.string   "uri",          :null => false
    t.text     "details"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "citations", ["retrieval_id", "uri"], :name => "index_citations_on_retrieval_id_and_uri", :unique => true
  add_index "citations", ["retrieval_id"], :name => "index_citations_on_retrieval_id"

  create_table "groups", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "histories", :force => true do |t|
    t.integer  "retrieval_id",                   :null => false
    t.integer  "year",                           :null => false
    t.integer  "month",                          :null => false
    t.integer  "citations_count", :default => 0
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "histories", ["retrieval_id", "year", "month"], :name => "index_histories_on_retrieval_id_and_year_and_month", :unique => true

  create_table "retrievals", :force => true do |t|
    t.integer  "article_id",                                               :null => false
    t.integer  "source_id",                                                :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "retrieved_at",          :default => '1970-01-01 00:00:00', :null => false
    t.integer  "citations_count",       :default => 0
    t.integer  "other_citations_count", :default => 0
    t.string   "local_id"
    t.boolean  "running"
  end

  add_index "retrievals", ["article_id", "citations_count", "other_citations_count"], :name => "retrievals_article_id"
  add_index "retrievals", ["source_id", "article_id"], :name => "index_retrievals_on_source_id_and_article_id", :unique => true

  create_table "sources", :force => true do |t|
    t.string   "type"
    t.string   "url"
    t.string   "username"
    t.string   "password"
    t.integer  "staleness",     :default => 604800
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "active",        :default => true
    t.string   "name"
    t.boolean  "live_mode",     :default => false
    t.string   "salt"
    t.string   "searchURL"
    t.integer  "timeout",       :default => 30,     :null => false
    t.integer  "group_id"
    t.datetime "disable_until"
    t.integer  "disable_delay", :default => 10,     :null => false
    t.string   "partner_id"
    t.text     "misc"
  end

  add_index "sources", ["type"], :name => "index_sources_on_type", :unique => true

  create_table "users", :force => true do |t|
    t.string   "login",                     :limit => 40
    t.string   "name",                      :limit => 100, :default => ""
    t.string   "email",                     :limit => 100
    t.string   "crypted_password",          :limit => 40
    t.string   "salt",                      :limit => 40
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "remember_token",            :limit => 40
    t.datetime "remember_token_expires_at"
  end

  add_index "users", ["login"], :name => "index_users_on_login", :unique => true

end
