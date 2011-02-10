class ChangeDefaultDisableDelay < ActiveRecord::Migration
  def self.up
    change_column :sources, :disable_delay, :int, :default => 10

    execute "update sources set disable_delay = 10;"
  end

  def self.down
    change_column :sources, :disable_delay, :int, :default => 900

    execute "update sources set disable_delay = 900;"
  end
end
