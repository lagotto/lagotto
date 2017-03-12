class StatusSerializer < ActiveModel::Serializer
  attributes :state, :jobs, :event_count, :source_count, :work_count
end
