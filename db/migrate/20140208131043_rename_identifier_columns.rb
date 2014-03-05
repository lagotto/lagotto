class RenameIdentifierColumns < ActiveRecord::Migration
  def change
    rename_column :articles, :mendeley, :mendeley_uuid
    rename_column :articles, :pub_med, :pmid
    rename_column :articles, :pub_med_central, :pmcid
    rename_column :articles, :url, :canonical_url
  end
end