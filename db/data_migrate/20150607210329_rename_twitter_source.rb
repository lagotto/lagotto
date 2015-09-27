class RenameTwitterSource < ActiveRecord::Migration
  def up
    twitter = Source.where(name: "twitter_search").update_all(name: "twitter")
  end

  def down
    twitter = Source.where(name: "twitter").update_all(name: "twitter_search")
  end
end
