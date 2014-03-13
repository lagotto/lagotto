module Delayed
  module Heartbeat
    class Plugin < Delayed::Plugin

      callbacks do |lifecycle|
        lifecycle.before(:execute) do |worker|
          @heartbeat = WorkerHeartbeat.new(worker.name) if Rails.configuration.jobs.heartbeat_enabled
        end

        lifecycle.after(:execute) do |worker|
          @heartbeat.stop if @heartbeat
        end
      end

    end
  end
end