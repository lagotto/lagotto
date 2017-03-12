class WorkSerializer < ActiveModel::Serializer
  cache key: 'work'
  attributes :doi, :url, :author, :title, :description, :license, :publisher, :provider, :updated


  def id
    object.to_param
  end

  def url
    object.pid
  end

  def author
    object.metadata.author
  end

  def title
    object.metadata.title
  end

  def description
    object.metadata.description
  end

  def license
    object.metadata.license
  end

  def publisher
    #object.metadata.publisher
  end

  def provider
    object.provider_id
  end

  def date_published
    object.metadata.date_published
  end

  def updated
    object.updated_at
  end
end
