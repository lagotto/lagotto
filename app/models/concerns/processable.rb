module Processable
  extend ActiveSupport::Concern

  included do
    def queue_event_job
      EventJob.set(wait: 3.minutes).perform_later(self)
    end

    # Called as part of EventJob.
    def process_data
      self.start

      if collect_data
        self.finish
      else
        self.error
      end
    end

    def collect_data
      update_relations
    end

    # update in order, stop if an error occured
    def update_relations
      update_work &&
      update_related_work
    end

    def update_work
      # initialize work if it doesn't exist
      self.work = Work.where(pid: subj_id).first_or_create
    rescue ActiveRecord::RecordInvalid, ActiveRecord::RecordNotUnique, ActiveRecord::StaleObjectError, ActiveRecord::StatementInvalid => exception
      self.work = Work.where(pid: pid).first
    end

    def update_related_work
      # initialize related_work if it doesn't exist
      self.related_work = Work.where(pid: obj_id).first_or_create
    rescue ActiveRecord::RecordInvalid, ActiveRecord::RecordNotUnique, ActiveRecord::StaleObjectError, ActiveRecord::StatementInvalid => exception
      self.related_work = Work.where(pid: obj_id).first
    end
  end
end
