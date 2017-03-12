class SimpleWorkSerializer < ActiveModel::Serializer
  cache key: 'simple_work'
  attributes :doi, :url, :provider_id, :updated

  def id
    object.to_param
  end

  def url
    object.pid
  end

  def updated
    object.updated_at
  end
end
