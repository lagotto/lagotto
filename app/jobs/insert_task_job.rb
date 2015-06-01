class InsertTaskJob < ActiveJob::Base
  queue_as :critical

  def perform(agent, ids = [])
    agent.insert_tasks(ids)
  end
end
