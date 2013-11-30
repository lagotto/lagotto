class AddApiCacheKeysTable < ActiveRecord::Migration
  def up
    create_table :api_cache_keys do |t|
      t.string   :name, null: false
      t.timestamps
    end

    change_column_default(:sources, :state, nil)
  end

  def down
    drop_table :api_cache_keys
    change_column_default(:sources, :state, 0)
  end
end
