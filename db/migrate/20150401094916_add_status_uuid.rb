class AddStatusUuid < ActiveRecord::Migration
  def up
    add_column :status, :uuid, :string
    add_column :alerts, :uuid, :string
    add_column :api_requests, :uuid, :string

    Status.where(uuid: nil).update_all(uuid: SecureRandom.uuid) if !!Status rescue false
    Alert.unscoped.where(uuid: nil).update_all(uuid: SecureRandom.uuid) if !!Alert rescue false
    ApiRequest.where(uuid: nil).update_all(uuid: SecureRandom.uuid) if !!ApiRequest rescue false
  end

  def down
    remove_column :status, :uuid
    remove_column :alerts, :uuid
    remove_column :api_requests, :uuid
  end
end
