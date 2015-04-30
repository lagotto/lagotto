class AddTrackedIndex < ActiveRecord::Migration
  def up
    add_index "works", ["tracked", "published_on"], name: "index_works_on_tracked_published_on"
  end

  def down
    add_index "works", name: "index_works_on_tracked_published_on"
  end
end
