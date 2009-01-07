class AddPubmedToArticles < ActiveRecord::Migration
  def self.up
    add_column "articles", "pub_med", :string
    add_column "articles", "pub_med_central", :string
  end

  def self.down
    remove_column "articles", "pub_med"
    remove_column "articles", "pub_med_central"
  end
end
