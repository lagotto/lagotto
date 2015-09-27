class CreateArticles < ActiveRecord::Migration
  def change
    create_table :articles do |t|
      t.string   :doi, limit: 191, :null => false  # doi of the article
      t.text     :title                # title of the article
      t.date     :published_on         # article publish date
      t.string   :pub_med, limit: 191  # pub med id
      t.string   :pub_med_central, limit: 191 # pub med central id

      t.timestamps
    end

    add_index :articles, :doi, :unique => true
  end
end
