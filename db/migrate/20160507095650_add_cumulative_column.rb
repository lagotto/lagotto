class AddCumulativeColumn < ActiveRecord::Migration
  def change
    add_column :sources, :cumulative, :boolean, default: false
  end
end
