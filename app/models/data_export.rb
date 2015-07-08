class DataExport < ActiveRecord::Base
  class Error < ::StandardError ; end
  class FileNotFoundError < Error ; end
  class FilePermissionError < Error ; end

  def self.data_attribute(name, options={})
    reader_method, writer_method = name, "#{name}="
    define_method(reader_method){ self.data[reader_method] || options[:default] }
    define_method(writer_method){ |value| self.data[name] = value }
  end

  scope :not_exported, -> { where(started_exporting_at:nil, finished_exporting_at:nil) }

  serialize :data, Hash
  serialize :files, Array

  validates :files, presence: true

  def export!
    raise NotImplementedError, "Must implement #export! in subclass!"
  end
end
