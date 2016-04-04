class AddEventableColumn < ActiveRecord::Migration
  def up
    add_column :sources, :eventable, :boolean, default: true

    list = ["copernicus","counter","figshare","pmc","bitbucket","mendeley","facebook","scopus","wos"]
    unevented_sources = Source.where("name IN (?)", list).update_all(eventable: false)
  end

  def down
    remove_column :sources, :eventable
  end
end
