class SourceSerializer < ActiveModel::Serializer
  cache key: 'source'
  attributes :title, :group_id, :description, :updated

  def id
    object.to_param
  end

  def updated
    object.updated_at
  end
end
