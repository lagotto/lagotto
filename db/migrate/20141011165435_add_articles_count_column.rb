class AddArticlesCountColumn < ActiveRecord::Migration
  def up
    add_column :publishers, :articles_count, :integer, null: false, default: 0
    # reset cached counts for publishers
    Publisher.all.each do |publisher|
      Publisher.reset_counters(publisher.id, :articles)
    end
    add_index :publishers, [:crossref_id], :unique => true
  end

  def down
    remove_column :publishers, :articles_count
    remove_index :publishers, [:crossref_id]
  end
end
