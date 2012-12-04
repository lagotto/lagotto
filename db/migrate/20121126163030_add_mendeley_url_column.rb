class AddMendeleyUrlColumn < ActiveRecord::Migration
  def up
    add_column :articles, :mendeley_url, :string
  end

  def down
    remove_column :articles, :mendeley_url
  end
end
