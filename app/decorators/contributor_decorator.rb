class ContributorDecorator < Draper::Decorator
  delegate_all

  def self.collection_decorator_class
    PaginatingDecorator
  end

  def id
    pid
  end

  def family
    family_name
  end

  def given
    given_names
  end

  def ORCID
    pid
  end
end
