class InitialMigration < ActiveRecord::Migration
  def up
     create_table "data_migrations", force: :cascade do |t|
      t.string "version", limit: 191
    end

    create_table "deposits", force: :cascade do |t|
      t.text     "uuid",                   limit: 65535,                      null: false
      t.string   "message_type",           limit: 191,   default: "relation", null: false
      t.string   "source_token",           limit: 255
      t.text     "callback",               limit: 65535
      t.integer  "state",                  limit: 4,     default: 0
      t.string   "state_event",            limit: 255
      t.datetime "created_at",                                                null: false
      t.datetime "updated_at",                                                null: false
      t.string   "message_action",         limit: 191,   default: "add",      null: false
      t.string   "prefix",                 limit: 191
      t.string   "subj_id",                limit: 191
      t.string   "obj_id",                 limit: 191
      t.string   "relation_type_id",       limit: 191
      t.string   "source_id",              limit: 191
      t.string   "publisher_id",           limit: 191
      t.text     "subj",                   limit: 65535
      t.text     "obj",                    limit: 65535
      t.integer  "total",                  limit: 4,     default: 1
      t.datetime "occurred_at"
      t.text     "error_messages",         limit: 65535
      t.integer  "work_id",                limit: 4
      t.integer  "related_work_id",        limit: 4
      t.integer  "contributor_id",         limit: 4
      t.string   "registration_agency_id", limit: 191
    end

    add_index "deposits", ["prefix", "created_at"], name: "index_deposits_on_prefix_created_at", using: :btree
    add_index "deposits", ["registration_agency_id"], name: "index_deposits_on_registration_agency_id", using: :btree
    add_index "deposits", ["source_id", "created_at"], name: "index_deposits_on_source_id_created_at", using: :btree
    add_index "deposits", ["updated_at"], name: "index_deposits_on_updated_at", using: :btree

    create_table "sources", force: :cascade do |t|
      t.string   "name",        limit: 191
      t.string   "title",       limit: 255,                                   null: false
      t.string   "group_id",    limit: 191
      t.boolean  "private",                   default: false
      t.datetime "created_at"
      t.datetime "updated_at"
      t.text     "description", limit: 65535
      t.boolean  "active",                    default: false
      t.datetime "cached_at",                 default: '1970-01-01 00:00:00', null: false
      t.boolean  "cumulative",                default: false
    end

    add_index "sources", ["active"], name: "index_sources_on_active", using: :btree
    add_index "sources", ["group_id"], name: "sources_group_id_fk", using: :btree
    add_index "sources", ["name"], name: "index_sources_on_name", unique: true, using: :btree

    create_table "works", force: :cascade do |t|
      t.string   "doi",                    limit: 191
      t.text     "title",                  limit: 65535
      t.date     "published_on"
      t.string   "pmid",                   limit: 191
      t.string   "pmcid",                  limit: 191
      t.datetime "created_at"
      t.datetime "updated_at"
      t.text     "canonical_url",          limit: 65535
      t.integer  "year",                   limit: 4,        default: 1970
      t.integer  "month",                  limit: 4
      t.integer  "day",                    limit: 4
      t.string   "publisher_id",           limit: 191
      t.text     "pid",                    limit: 65535,                                    null: false
      t.text     "csl",                    limit: 16777215
      t.boolean  "tracked",                                 default: false
      t.string   "scp",                    limit: 191
      t.string   "wos",                    limit: 191
      t.string   "ark",                    limit: 191
      t.string   "arxiv",                  limit: 191
      t.string   "dataone",                limit: 191
      t.integer  "lock_version",           limit: 4,        default: 0,                     null: false
      t.datetime "issued_at",                               default: '1970-01-01 00:00:00', null: false
      t.text     "handle_url",             limit: 65535
      t.string   "registration_agency_id", limit: 191
      t.string   "member_id",              limit: 191
      t.string   "resource_type_id",       limit: 191
      t.string   "resource_type",          limit: 191
      t.datetime "deposited_at",                            default: '1970-01-01 00:00:00', null: false
      t.string   "schema",                 limit: 191
      t.string   "schema_version",         limit: 191
      t.binary   "xml",                    limit: 65535
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
    add_index "works", ["issued_at"], name: "index_on_issued_at", using: :btree
    add_index "works", ["member_id"], name: "works_member_id_fk", using: :btree
    add_index "works", ["pid"], name: "index_works_on_pid", unique: true, length: {"pid"=>191}, using: :btree
    add_index "works", ["pmcid", "published_on", "id"], name: "index_works_on_pmcid_published_on_id", using: :btree
    add_index "works", ["pmcid"], name: "index_works_on_pmcid", unique: true, using: :btree
    add_index "works", ["pmid", "published_on", "id"], name: "index_works_on_pmid_published_on_id", using: :btree
    add_index "works", ["pmid"], name: "index_works_on_pmid", unique: true, using: :btree
    add_index "works", ["published_on"], name: "index_works_on_published_on", using: :btree
    add_index "works", ["publisher_id", "published_on"], name: "index_works_on_publisher_id_and_published_on", using: :btree
    add_index "works", ["registration_agency_id"], name: "index_on_registration_agency_id", using: :btree
    add_index "works", ["resource_type_id"], name: "works_resource_type_id_fk", using: :btree
    add_index "works", ["scp", "published_on", "id"], name: "index_works_on_scp_published_on_id", using: :btree
    add_index "works", ["scp"], name: "index_works_on_scp", unique: true, using: :btree
    add_index "works", ["tracked", "published_on"], name: "index_works_on_tracked_published_on", using: :btree
    add_index "works", ["wos", "published_on", "id"], name: "index_works_on_wos_published_on_id", using: :btree
    add_index "works", ["wos"], name: "index_works_on_wos", unique: true, using: :btree
  end
end
