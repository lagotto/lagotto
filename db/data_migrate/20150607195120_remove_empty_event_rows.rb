class RemoveEmptyEventRows < ActiveRecord::Migration
  def up
    Event.where(total: 0).destroy_all
  end

  def down

  end
end
