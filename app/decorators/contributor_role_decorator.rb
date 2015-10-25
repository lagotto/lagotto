class ContributorRoleDecorator < Draper::Decorator
  delegate_all

  def id
    to_param
  end

  def image_url
    "https://s3.amazonaws.com/mozillascience/badges/#{model.name}.png"
  end
end
