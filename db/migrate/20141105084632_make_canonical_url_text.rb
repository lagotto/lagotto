class MakeCanonicalUrlText < ActiveRecord::Migration
  def up
    change_column :articles, :canonical_url, :text
  end

  def down
    change_column :articles, :canonical_url, :string
  end
end
