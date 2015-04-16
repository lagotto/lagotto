class ApiRequestDecorator < Draper::Decorator
  delegate_all

  def self.collection_decorator_class
    PaginatingDecorator
  end

  def id
    to_param
  end

  def source
    model.source
  end
end
