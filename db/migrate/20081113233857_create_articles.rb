class CreateArticles < ActiveRecord::Migration
  def self.up
    create_table :articles do |t|
      t.string :doi, :null => false

      t.timestamps
    end
  end

  def self.down
    drop_table :articles
  end
end
