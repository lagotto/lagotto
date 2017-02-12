class WorkSerializer < ActiveModel::Serializer
  cache key: 'work'
  attributes :doi, :url, :author, :title, :container_title, :resource_type_id, :resource_type, :registration_agency_id, :schema_version, :published, :deposited, :updated, :xml

  def id
    object.to_param
  end

  def url
    object.canonical_url
  end

  def published
    object.published_on
  end

  def deposited
    object.deposited_at
  end

  def updated
    object.updated_at
  end
end
