class Ability
  include CanCan::Ability

  # To simplify, all admin permissions are linked to the ErrorMessage resource

  def initialize(user)
    user ||= User.new(:role => "anonymous") # Guest user
    if user.role == "admin"
      can :manage, :all
    elsif user.role == "staff"
      can :read, :all
      can :update, User, :id => user.id
    elsif user.role == "user"
      can [:update, :show], User, :id => user.id
    else
    end
  end
end
