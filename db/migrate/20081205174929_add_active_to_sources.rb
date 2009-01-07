class AddActiveToSources < ActiveRecord::Migration
  class Source < ActiveRecord::Base; end

  def self.up
    add_column :sources, :active, :boolean, :default => true
  end

  def self.down
    remove_column :sources, :active
  end
end
