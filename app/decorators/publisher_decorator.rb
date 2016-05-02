class PublisherDecorator < Draper::Decorator
  delegate_all

  def self.collection_decorator_class
    PaginatingDecorator
  end

  def id
    name
  end

  def registration_agency_id
    cached_registration_agency_names[model.registration_agency_id] if model.registration_agency.present?
  end

  def users
    object.users.map { |user| user.id }
  end

  def prefixes
    object.prefixes.map { |prefix| prefix.name }
  end
end
