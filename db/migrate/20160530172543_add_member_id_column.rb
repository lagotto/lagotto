class AddMemberIdColumn < ActiveRecord::Migration
  def change
    add_column :publishers, :member_id, :string, limit: 191
  end
end
