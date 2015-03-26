class DropWorkersTable < ActiveRecord::Migration
  def up
    drop_table :workers
  end

  def down
    create_table "workers", force: :cascade do |t|
      t.integer  "identifier", limit: 4,   null: false
      t.string   "queue",      limit: 255, null: false
      t.datetime "created_at"
      t.datetime "updated_at"
    end
  end
end
