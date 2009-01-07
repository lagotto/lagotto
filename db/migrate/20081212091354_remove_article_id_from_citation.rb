class RemoveArticleIdFromCitation < ActiveRecord::Migration
  def self.up
    remove_column :citations, :article_id
  end

  def self.down
    add_column :citations, :article_id, :integer
  end
end
