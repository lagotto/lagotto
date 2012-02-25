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

ActiveRecord::Schema.define(:version => 20120225001622) do

  create_table "articles", :force => true do |t|
    t.string   "doi",                                                :null => false
    t.datetime "retrieved_at",    :default => '1970-01-01 00:00:00', :null => false
    t.string   "pub_med"
    t.string   "pub_med_central"
    t.date     "published_on"
    t.text     "title"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

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
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "delayed_jobs", ["priority", "run_at"], :name => "delayed_jobs_priority"

  create_table "retrievals", :force => true do |t|
    t.integer  "article_id",                                      :null => false
    t.integer  "source_id",                                       :null => false
    t.datetime "queued_at"
    t.datetime "retrieved_at", :default => '1970-01-01 00:00:00', :null => false
    t.string   "data_rev"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "sources", :force => true do |t|
    t.string   "name",                             :null => false
    t.string   "display_name",                     :null => false
    t.boolean  "active",        :default => false
    t.datetime "disable_until"
    t.integer  "disable_delay", :default => 10,    :null => false
    t.integer  "timeout",       :default => 30,    :null => false
    t.integer  "batch_size",    :default => 100,   :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "sources", ["name"], :name => "index_sources_on_name", :unique => true

end
