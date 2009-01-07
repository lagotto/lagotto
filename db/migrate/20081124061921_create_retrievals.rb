class CreateRetrievals < ActiveRecord::Migration
  def self.up
    create_table :retrievals do |t|
      t.integer :article_id, :null => false
      t.integer :source_id, :null => false

      t.timestamps
    end
  end

  def self.down
    drop_table :retrievals
  end
end
