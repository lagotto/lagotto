class IncreaseSizeCslColumn < ActiveRecord::Migration
  def change
    change_column :works, :csl, :text, limit: 16777215
    change_column :works, :publisher_id, :integer, limit: 8
  end
end
