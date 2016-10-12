class ResultDecorator < Draper::Decorator
  delegate_all

  def self.collection_decorator_class
    PaginatingDecorator
  end

  def source_id
    cached_source_names.fetch(model.source_id, {}).fetch(:name, nil)
  end

  def work_id
    work.pid
  end
end
