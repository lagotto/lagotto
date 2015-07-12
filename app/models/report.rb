require 'zip'

class Report < ActiveRecord::Base
  # include HTTP request helpers
  include Networkable

  has_and_belongs_to_many :users

  serialize :config, OpenStruct

  def self.available(role)
    if role == "user"
      where(:private => false)
    else
      all
    end
  end

  def interval
    config.interval || 1.day
  end

  def interval=(value)
    config.interval = value.to_i
  end

  # Reports are sent via ActiveJob

  def send_error_report
    ReportMailer.send_error_report(self).deliver_later
  end

  def send_status_report
    ReportMailer.send_status_report(self).deliver_later
  end

  def send_work_statistics_report
    ReportMailer.send_work_statistics_report(self).deliver_later
  end

  def send_fatal_error_report(message)
    ReportMailer.send_fatal_error_report(self, message).deliver_later
  end

  def send_stale_source_report(source_ids)
    ReportMailer.send_stale_source_report(self, source_ids).deliver_later
  end

  def send_missing_workers_report
    ReportMailer.send_missing_workers_report(self).deliver_later
  end
end
