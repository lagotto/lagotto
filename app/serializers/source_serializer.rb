class SourceSerializer < ActiveModel::Serializer
  cache key: 'source'
  attributes :title, :description, :state, :updated

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
