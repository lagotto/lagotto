class GroupDecorator < Draper::Decorator
  delegate_all

  def id
    name
  end

  def sources
    object.sources.active.map { |source| source.name }
  end
end
