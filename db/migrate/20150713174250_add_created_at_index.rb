class AddCreatedAtIndex < ActiveRecord::Migration
  def up
    add_index "works", ["created_at"], name: "index_works_on_created_at"
  end

  def down
    remove_index "works", name: "index_works_on_created_at"
  end
end
