class GroupDecorator < Draper::Decorator  
  delegate_all
  decorates_finders
  decorates_association :sources
  
  def sources
    model.sources.active
  end
end