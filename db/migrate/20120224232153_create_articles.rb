class CreateArticles < ActiveRecord::Migration
  def change
    create_table :articles do |t|
      t.string   :doi, :null => false, :unique => true
      t.datetime :retrieved_at, :default => '1970-01-01 00:00:00', :null => false
      t.string   :pub_med
      t.string   :pub_med_central
      t.date     :published_on
      t.text     :title
      
      t.timestamps
    end
  end
end
