class AddScheduledAtColumn < ActiveRecord::Migration
  def self.up
    add_column :retrieval_statuses, :scheduled_at, :datetime
    # use SQL because it is faster for many rows.
    # start with staleness: 7.days
    execute "update retrieval_statuses set scheduled_at = TIMESTAMPADD(DAY,7,retrieved_at)"
  end

  def self.down
    remove_column :retrieval_statuses, :scheduled_at
  end
end
