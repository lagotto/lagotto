class RelationDecorator < Draper::Decorator
  delegate_all
  decorates_association :work
  decorates_association :related_work

  def self.collection_decorator_class
    PaginatingDecorator
  end

  def subj_id
    model.work.pid
  end

  def obj_id
    model.related_work.pid
  end

  def source_id
    cached_source_names[model.source_id]
  end

  def publisher_id
    cached_publisher_id(model.publisher_id).name if model.publisher_id.present?
  end

  def relation_type_id
    cached_relation_type_names[model.relation_type_id]
  end
end
