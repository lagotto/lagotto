class DepositSerializer < ActiveModel::Serializer
  cache key: 'deposit'
  attributes :id, :state, :message_type, :message_action, :source_token, :callback, :subj_id, :obj_id, :relation_type_id, :source_id, :publisher_id, :registration_agency_id, :total, :occurred_at, :timestamp, :subj, :obj

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
