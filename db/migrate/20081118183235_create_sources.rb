class CreateSources < ActiveRecord::Migration
  def self.up
    create_table :sources do |t|
      t.string :name
      t.string :url
      t.string :username
      t.string :password
      t.integer :staleness, :default => 7.days.to_i

      t.timestamps
    end
  end

  def self.down
    drop_table :sources
  end
end
