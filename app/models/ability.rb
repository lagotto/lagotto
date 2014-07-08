class Ability
  include CanCan::Ability

  # To simplify, all admin permissions are linked to the Alert resource

  def initialize(user)
    user ||= User.new(:role => "anonymous") # Guest user

    case user
    when "user", "publisher"
      can [:update, :show], User, :id => user.id
    when "admin"
      can :manage, :all
    when "staff"
      can :read, :all
      can :destroy, Alert
      can :create, Article
      can :update, User, :id => user.id
    end
  end
end
