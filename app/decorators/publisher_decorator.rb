class PublisherDecorator < Draper::Decorator
  delegate_all

  def self.collection_decorator_class
    PaginatingDecorator
  end

  def id
    member_id
  end

  def users
    object.users.map { |user| user.id }
  end
end
