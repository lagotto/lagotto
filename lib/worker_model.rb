# From http://www.salsify.com/blog/detect-failed-delayed-job-workers

module Delayed
  module Heartbeat
    class WorkerModel < ActiveRecord::Base
      self.table_name = 'delayed_workers'

      attr_accessible :name, :last_heartbeat_at

      before_create do |model|
        model.last_heartbeat_at ||= Time.now.utc
      end

      def update_heartbeat
        update_column(:last_heartbeat_at, Time.now.utc)
      end

      def self.dead_workers(timeout_minutes)
        where('last_heartbeat_at < ?', Time.now.utc - timeout_minutes.minutes)
      end

      def self.active_names
        select(:name)
      end

    end
  end
end