class AddArticlesPublisherIndex < ActiveRecord::Migration
  def up
    add_column :publishers, :cached_at, :datetime, default: '1970-01-01 00:00:00', null: false
    add_index :publishers, [:crossref_id], :unique => true
  end

  def down
    remove_column :publishers, :cached_at
    remove_index :publishers, [:crossref_id]
  end
end
