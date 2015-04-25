class RelationTypeDecorator < Draper::Decorator
  delegate_all

  def id
    to_param
  end

  def subgroup
    level > 0 ? "reference" : "version"
  end
end
