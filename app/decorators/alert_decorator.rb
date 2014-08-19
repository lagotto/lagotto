class AlertDecorator < Draper::Decorator
  delegate_all
  decorates_finders

  def level
    model.human_level_name
  end

  def source
    model.source.name
  end

  def article
    model.article.uid
  end
end
