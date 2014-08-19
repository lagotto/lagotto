class AlertDecorator < Draper::Decorator
  delegate_all
  decorates_finders

  def article
    article.uid
  end

  def source
    source.name
  end
end
