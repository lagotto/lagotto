class AddMessageSize < ActiveRecord::Migration
  def change
    add_column :deposits, :message_action, :string, default: 'create', null: false
  end
end
