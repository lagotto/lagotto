class RelationshipDecorator < Draper::Decorator
  delegate_all
  decorates_association :work
  decorates_association :related_work

  def self.collection_decorator_class
    PaginatingDecorator
  end

  def work_id
    model.work.pid
  end

  def source_id
    model.source.name
  end

  def relation_type_id
    model.relation_type.name
  end
end
