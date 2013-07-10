class Ability
  include CanCan::Ability
  
  # To simplify, all admin permissions are linked to the ErrorMessage resource

  def initialize(user)
    user ||= User.new(:role => "anonymous") # Guest user
    if user.role == "admin"
      can :manage, :all
    elsif user.role == "staff"
      can :manage, User, :id => user.id
      can :read, [Article, Source, ErrorMessage, ApiRequest, DelayedJob]
    elsif user.role == "user"
      can :manage, User, :id => user.id
      can :read, [Article, Source]
    else
      can :read, [Article, Source]
    end
  end
end