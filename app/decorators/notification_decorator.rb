class NotificationDecorator < Draper::Decorator
  delegate_all
  decorates_finders

  def self.collection_decorator_class
    PaginatingDecorator
  end

  def id
    to_param
  end

  def level
    model.human_level_name
  end

  def source_id
    model.source ? model.source.name : nil
  end

  def work_id
    model.work ? model.work.to_param : nil
  end

  def timestamp
    model.create_date
  end
end
