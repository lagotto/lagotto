class AggregationDecorator < Draper::Decorator
  delegate_all
  decorates_finders

  def self.collection_decorator_class
    PaginatingDecorator
  end

  def id
    to_param
  end

  def source_id
    source.name
  end

  def work_id
    work.pid
  end

  def display_name
    title
  end
end
