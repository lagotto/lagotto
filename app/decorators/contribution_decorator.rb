class ContributionDecorator < Draper::Decorator
  delegate_all
  decorates_association :work
  decorates_association :contributor
  decorates_association :contributor_role

  def self.collection_decorator_class
    PaginatingDecorator
  end

  def subj_id
    model.contributor.pid
  end

  def obj_id
    model.work.pid
  end

  def source_id
    cached_source_names[model.source_id]
  end

  def publisher_id
    cached_publisher_names[model.publisher_id]
  end

  def contributor_role_id
    cached_contributor_role_names.fetch(model.contributor_role_id, "contribution")
  end
end
