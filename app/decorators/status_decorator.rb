class StatusDecorator < Draper::Decorator
  delegate_all
  decorates_finders

  def self.collection_decorator_class
    PaginatingDecorator
  end

  def id
    to_param
  end

  def cache_key
    "status/#{context[:role]}/#{timestamp}"
  end
end
