class PrefixDecorator < Draper::Decorator
  delegate_all

  def id
    model.name
  end

  def publisher_id
    cached_publisher_id(model.publisher_id).name if model.publisher_id.present?
  end

  def registration_agency_id
    cached_registration_agency_names.fetch(model.registration_agency_id, {}). fetch(:name, nil)
  end
end
