class MakeDoiColumnNullable < ActiveRecord::Migration
  def change
    change_column :articles, :doi, :string, limit: 191, null: true
  end
end
