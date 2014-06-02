class MakeDoiColumnNullable < ActiveRecord::Migration
  def change
    change_column :articles, :doi, :string, null: true
  end
end
