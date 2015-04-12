class RelationDecorator < Draper::Decorator
  delegate_all
  decorates_association :work
  decorates_association :related_work

  def self.collection_decorator_class
    PaginatingDecorator
  end

  def relation_type_id
    model.relation_type.name
  end

  def reference_id
    model.work.pid
  end

  def event_id
    model.related_work.pid
  end

  def source_id
    model.source.name
  end
end
