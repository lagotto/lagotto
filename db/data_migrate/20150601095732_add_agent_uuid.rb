class AddAgentUuidColumn < ActiveRecord::Migration
  def up
    Agent.where(uuid: nil).update_all(uuid: SecureRandom.uuid)
  end

  def down

  end
end
