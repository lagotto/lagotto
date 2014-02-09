class RenameIdentifierColumns < ActiveRecord::Migration
  def change
    rename_column :articles, :mendeley, :mendeley_uuid
    rename_column :articles, :pub_med, :pmid
    rename_column :articles, :pub_med_central, :pmcid
    rename_column :articles, :url, :canonical_url
  end

  def up
    add_column :articles, :year, :integer
    add_column :articles, :month, :integer
    add_column :articles, :day, :integer
  end

  def down
    remove_column :articles, :year
    remove_column :articles, :month
    remove_column :articles, :day
  end
end