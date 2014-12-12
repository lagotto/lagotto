class AlertDecorator < Draper::Decorator
  delegate_all
  decorates_finders

  def self.collection_decorator_class
    PaginatingDecorator
  end

  def level
    model.human_level_name
  end

  def source
    source_id ? model.source.name : nil
  end

  def work
    work_id ? model.work.uid : nil
  end
end
