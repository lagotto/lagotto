class Ability
  include CanCan::Ability

  # To simplify, all admin permissions are linked to the Notification resource

  def initialize(user)
    user ||= User.new(:role => "anonymous") # Guest user

    if user.role == "admin"
      can :manage, :all
    elsif user.role == "staff"
      can :read, :all
      # publisher-specific agent configuration
      can :update, Agent do |agent|
        user.publisher && agent.by_publisher?
      end
      can [:update, :show], User, :id => user.id
    elsif user.role == "user"
      # publisher-specific agent configuration
      can :update, Source do |agent|
        user.publisher && agent.by_publisher?
      end
      can [:update, :show], User, :id => user.id
    else
    end
  end
end
