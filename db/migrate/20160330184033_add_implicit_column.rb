class AddImplicitColumn < ActiveRecord::Migration
  def change
    add_column :relations, :implicit, :boolean, default: false
  end
end
