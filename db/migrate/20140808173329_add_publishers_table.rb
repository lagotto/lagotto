class AddPublishersTable < ActiveRecord::Migration
  def change
    create_table :publishers do |t|
      t.string :name
      t.integer :crossref_id
      t.text :prefixes
      t.text :other_names
      t.timestamps
    end

    create_table :publisher_options do |t|
      t.belongs_to :publisher
      t.belongs_to :source
      t.string :config
      t.timestamps
    end

    add_column :users, :publisher_id, :integer
    add_column :articles, :publisher_id, :string, limit: 191
  end
end
