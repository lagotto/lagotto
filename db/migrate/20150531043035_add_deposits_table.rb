class AddDepositsTable < ActiveRecord::Migration
  def up
    create_table "deposits", force: true do |t|
      t.text     "uuid",                         null: false
      t.string   "message_type",                 null: false
      t.text     "message",                      limit: 2048.kilobytes + 1
      t.string   "source_token"
      t.text     "callback"
      t.integer  "state",                        default: 0
      t.string   "state_event"
      t.datetime "created_at",                   null: false
      t.datetime "updated_at",                   null: false
    end

    add_index "deposits", ["updated_at"], name: "index_deposits_on_updated_at"
  end

  def down
    drop_table :deposits
  end
end
