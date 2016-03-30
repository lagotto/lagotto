class AddImplicitColumn < ActiveRecord::Migration
  def change
    add_column :relations, :implicit, :boolean, default: false
    add_column :contributors, :github, :string, limit: 191
    add_column :contributors, :literal, :string, limit: 191
  end
end
