class AddContributorRoleTable < ActiveRecord::Migration
  def up
    create_table "contributors", force: :cascade do |t|
      t.string   "pid",           limit: 191,             null: false
      t.string   "orcid",         limit: 191,             null: false
      t.string   "given_names",   limit: 255
      t.string   "family_name",   limit: 255
      t.datetime "submitted_at"
      t.datetime "cached_at",     default: '1970-01-01 00:00:00', null: false
      t.datetime "created_at",                            null: false
      t.datetime "updated_at",                            null: false
    end

    add_index "contributors", ["pid"], name: "index_contributors_on_pid", using: :btree
    add_index "contributors", ["orcid"], name: "index_contributors_on_orcid", using: :btree

    create_table "contributor_roles", force: :cascade do |t|
      t.string   "name",          limit: 255,             null: false
      t.string   "title",         limit: 255
      t.text     "description",   limit: 65535
      t.datetime "created_at",                            null: false
      t.datetime "updated_at",                            null: false
    end

    create_table "contributions", force: :cascade do |t|
      t.integer  "work_id",          limit: 4,             null: false
      t.integer  "contributor_id",   limit: 4,             null: false
      t.integer  "source_id",        limit: 4
      t.integer  "contributor_role_id", limit: 4
      t.datetime "created_at",                             null: false
      t.datetime "updated_at",                             null: false
    end

    add_index "contributions", ["contributor_id"], name: "index_contributions_on_contributor_id", using: :btree
    add_index "contributions", ["contributor_role_id"], name: "index_contributions_on_contributor_role_id", using: :btree
    add_index "contributions", ["source_id"], name: "index_contributions_on_source_id", using: :btree
    add_index "contributions", ["work_id", "contributor_id", "source_id"], name: "index_contributions_on_work_id_and_contributor_id_and_source_id", unique: true, using: :btree

    add_column :status, :contributors_count, :integer, default: 0
    add_column :status, :publishers_count, :integer, default: 0
  end

  def down
    drop_table :contributors
    drop_table :contributor_roles
    drop_table :contributions

    remove_column :status, :contributors_count
    remove_column :status, :publishers_count
  end
end
