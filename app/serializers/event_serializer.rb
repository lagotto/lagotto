class EventSerializer < ActiveModel::Serializer
  cache key: 'event'
  attributes :id, :state, :message_action, :source_token, :callback, :subj_id, :obj_id, :relation_type_id, :source_id, :total, :occurred_at, :subj, :obj

  def id
    object.to_param
  end

  def state
    object.human_state_name
  end

  def updated
    object.updated_at
  end
end
