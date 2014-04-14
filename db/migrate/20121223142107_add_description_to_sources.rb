class AddDescriptionToSources < ActiveRecord::Migration
  def up
    add_column :sources, :description, :text
  end

  def down
    remove_column :sources, :description
  end
end
