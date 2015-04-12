class AddEventableColumn < ActiveRecord::Migration
  def up
    list = ["copernicus","counter","figshare","pmc","bitbucket","mendeley","facebook","scopus","wos"]
    unevented_sources = Source.where("name IN (?)", list).update_all(eventable: false)
  end

  def down

  end
end
