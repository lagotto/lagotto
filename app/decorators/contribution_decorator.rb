class ContributionDecorator < Draper::Decorator
  delegate_all
  decorates_association :work
  decorates_association :contributor
  decorates_association :contributor_role

  def self.collection_decorator_class
    PaginatingDecorator
  end

  def contributor_id
    model.contributor.pid
  end

  def work_id
    model.work.pid
  end

  def source_id
    model.source.name
  end

  def contributor_role_id
    if model.contributor_role_id.present?
      nil #model.contributor_role.name
    end
  end
end
