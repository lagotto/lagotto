class AddGroups < ActiveRecord::Migration
  def self.up
    create_table :groups do |t|
      t.string :name
      t.timestamps
    end
    
    add_column :sources, :group_id, :integer, { :null => true }
    
    execute "insert into groups(name) values('Social Bookmarks');"
    execute "insert into groups(name) values('Citations');"
    execute "insert into groups(name) values('Blog Entries');"
    execute "insert into groups(name) values('Usage Statistics');"
  end

  def self.down
    remove_column :sources,:group_id
    
    drop_table :groups
  end
end
