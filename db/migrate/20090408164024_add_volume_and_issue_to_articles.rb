class AddVolumeAndIssueToArticles < ActiveRecord::Migration
  def self.up
    add_column :articles, :volume, :string
    add_column :articles, :issue, :string
  end

  def self.down
    remove_column :articles, :volume
    remove_column :articles, :issue
  end
end
