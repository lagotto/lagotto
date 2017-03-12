class Ability
  include CanCan::Ability

  def initialize(user)
    user ||= User.new(:role => "anonymous") # Guest user

    if user.role == "admin"
      can :manage, :all
    elsif user.role == "staff"
      can :read, :all
    elsif user.role == "contributor"
      can :manage, [Work, Event]
    else
    end
  end
end
