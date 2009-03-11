class AddIndices < ActiveRecord::Migration
  def self.up
    add_index :citations, :retrieval_id
    add_index :retrievals,
      %w[article_id citations_count other_citations_count],
      :name => "retrievals_article_id"
  end

  def self.down
    remove_index :citations, :retrieval_id
    remove_index :retrievals, :name => "retrievals_article_id"
  end
end
