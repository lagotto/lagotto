require 'poise'

class Chef
  class Resource::Firewall < Resource
    include Poise(:container => true)

    actions(:enable, :disable, :flush, :save)
    attribute(:log_level, :kind_of => [Symbol, String], :equal_to => [:low, :medium, :high, :full, 'low', 'medium', 'high', 'full'], :default => :low)
  end
end
