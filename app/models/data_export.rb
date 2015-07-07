class DataExport < ActiveRecord::Base
  class Error < ::StandardError ; end
  class FileNotFoundError < Error ; end
  class FilePermissionError < Error ; end

  scope :not_exported, -> { where(started_exporting_at:nil, finished_exporting_at:nil) }

  serialize :data, Hash
  serialize :files, Array

  def export!
    raise NotImplementedError, "Must implement #export! in subclass!"
  end
end
