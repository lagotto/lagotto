class AddStatusUuid < ActiveRecord::Migration
  def up
    add_column :status, :uuid, :string
    add_column :alerts, :uuid, :string
    add_column :api_requests, :uuid, :string
  end

  def down
    remove_column :status, :uuid
    remove_column :alerts, :uuid
    remove_column :api_requests, :uuid
  end
end
