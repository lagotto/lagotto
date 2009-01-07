class CreateCitations < ActiveRecord::Migration
  def self.up
    create_table :citations do |t|
      t.integer :article_id
      t.integer :retrieval_id
      t.string :uri
      t.text :abstract

      t.timestamps
    end
    
    add_column :articles, :citations_count, :integer, :default => 0

    Citation.reset_column_information
    Article.reset_column_information
    Article.find(:all).each do |article|
      Article.update_counters(article.id, 
        :citations_count => article.citations.length)
    end
  end

  def self.down
    drop_table :citations
  end
end
