class AddHostnameColumn < ActiveRecord::Migration
  def up
    add_column :alerts, :hostname, :string
  end

  def down
    remove_column :alerts, :hostname
  end
end
