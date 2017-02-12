class StatusSerializer < ActiveModel::Serializer
  attributes :state, :jobs, :deposit_count, :source_count, :work_count
end
