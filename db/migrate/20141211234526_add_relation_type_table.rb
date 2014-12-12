class AddRelationTypeTable < ActiveRecord::Migration
  def up
    add_column :works, :pid_type, :string, null: false
    add_column :works, :pid, :string, null: false
    add_column :works, :csl, :text
    add_column :works, :work_type_id, :integer
    add_column :works, :response_id, :integer

    remove_index "works", name: "index_articles_doi_published_on_article_id"
    remove_index "works", name: "index_works_on_doi"

    create_table "events", :force => true do |t|
      t.integer  "work_id",                                          null: false
      t.integer  "citation_id",                                      null: false
      t.integer  "source_id"
      t.integer  "relation_type_id",                                 null: false
      t.datetime "created_at",                                       null: false
      t.datetime "updated_at",                                       null: false
    end

    create_table "work_types", :force => true do |t|
      t.string  "name",                                              null: false
      t.datetime "created_at",                                       null: false
      t.datetime "updated_at",                                       null: false
    end

    create_table "relation_types", :force => true do |t|
      t.string  "name",                                              null: false
      t.datetime "created_at",                                       null: false
      t.datetime "updated_at",                                       null: false
    end
  end

  def down
    remove_column :works, :pid_type
    remove_column :works, :pid
    remove_column :works, :csl
    remove_column :works, :work_type_id
    remove_column :works, :response_id

    add_index "works", ["doi", "published_on", "id"], name: "index_articles_doi_published_on_article_id"
    add_index "works", ["doi"], name: "index_works_on_doi", unique: true

    drop_table :events
    drop_table :work_types
    drop_table :relation_types
  end
end
