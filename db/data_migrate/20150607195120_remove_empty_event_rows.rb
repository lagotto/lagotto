class RemoveEmptyEventRows < ActiveRecord::Migration
  def up
    Event.where(total: 0).delete_all
    Month.where('event_id NOT IN (SELECT id FROM events)').delete_all
    Day.where('event_id NOT IN (SELECT id FROM events)').delete_all
  end

  def down

  end
end
