class AddDatePartsColumns < ActiveRecord::Migration
  def change
    add_column :articles, :year, :integer, default: 1970
    add_column :articles, :month, :integer, default: nil
    add_column :articles, :day, :integer, default: nil
  end
end
