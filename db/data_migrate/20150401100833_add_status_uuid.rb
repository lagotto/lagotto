class AddStatusUuid < ActiveRecord::Migration
  def up
    Status.where(uuid: nil).update_all(uuid: SecureRandom.uuid)
    Alert.unscoped.where(uuid: nil).update_all(uuid: SecureRandom.uuid)
    ApiRequest.where(uuid: nil).update_all(uuid: SecureRandom.uuid)
  end

  def down

  end
end
