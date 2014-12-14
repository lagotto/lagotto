class AddPublisherColumns < ActiveRecord::Migration
  def up
    rename_column :publishers, :crossref_id, :member_id
    rename_column :publishers, :name, :title
    add_column :publishers, :name, :string, null: false
    add_column :publishers, :service, :string
  end

  def down
    remove_column :publishers, :name
    remove_column :publishers, :service
    rename_column :publishers, :member_id, :crossref_id
    rename_column :publishers, :title, :name
  end
end
