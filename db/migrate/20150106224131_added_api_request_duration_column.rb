class AddedApiRequestDurationColumn < ActiveRecord::Migration
  def up
    add_column :api_requests, :duration, :float, limit: 24
  end

  def down
    remove_column :api_requests, :duration
  end
end
