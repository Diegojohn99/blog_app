class Ability
  include CanCan::Ability

  def initialize(user)
    user ||= User.new

    can :read, Article
    
    return unless user.persisted?

    if user.admin?
      can :manage, :all
    elsif user.moderator?
      can :manage, Article
      can :manage, User, id: user.id
    elsif user.user?
      can :read, Article
      can :create, Article
      can :update, Article, user_id: user.id
      can :destroy, Article, user_id: user.id
      can :manage, User, id: user.id
    end
  end
end
