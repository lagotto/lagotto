class Ability
  include CanCan::Ability

  # To simplify, all admin permissions are linked to the Alert resource

  def initialize(user)
    user ||= User.new(:role => "anonymous") # Guest user

    if user.role == "admin"
      can :manage, :all
    elsif user.role == "staff"
      can :read, :all
      can :destroy, Alert
      can :create, Article
      can :manage, User, :id => user.id
    elsif user.role == "publisher"
      can :read, Source
      can :manage, User, :id => user.id
    elsif user.role == "user"
      can [:update, :show], User, :id => user.id
    else
    end
  end
end
