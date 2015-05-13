class AddPidIndex < ActiveRecord::Migration
  def up
    add_index "works", ["pid"], name: "index_works_on_pid", unique: true
  end

  def down
    remove_index "works", name: "index_works_on_pid"
  end
end
