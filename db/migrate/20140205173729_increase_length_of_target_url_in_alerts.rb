class IncreaseLengthOfTargetUrlInAlerts < ActiveRecord::Migration
  def change
    change_column :alerts, :target_url, :string, :null=>true, :limit => 1000

  end
end
