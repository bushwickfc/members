class Ability
  include CanCan::Ability

  def initialize(user)
    if user && user.admin?
      Rails.logger.debug("FOO ADMIN")
      can :manage, :all
    elsif user
      can :manage, :all do |obj|
        Rails.logger.debug("FOO CHECK")
        Rails.logger.debug(obj.inspect)
        Rails.logger.debug(user.inspect)
        case obj
        when Member then obj.id == user.id
        else obj.member_id == user.id
        end
      end
    else
      Rails.logger.debug("FOO NO")
      cannot :manage, :all
    end
    # Define abilities for the passed in user here. For example:
    #
    #   user ||= User.new # guest user (not logged in)
    #   if user.admin?
    #     can :manage, :all
    #   else
    #     can :read, :all
    #   end
    #
    # The first argument to `can` is the action you are giving the user 
    # permission to do.
    # If you pass :manage it will apply to every action. Other common actions
    # here are :read, :create, :update and :destroy.
    #
    # The second argument is the resource the user can perform the action on. 
    # If you pass :all it will apply to every resource. Otherwise pass a Ruby
    # class of the resource.
    #
    # The third argument is an optional hash of conditions to further filter the
    # objects.
    # For example, here the user can only update published articles.
    #
    #   can :update, Article, :published => true
    #
    # See the wiki for details:
    # https://github.com/ryanb/cancan/wiki/Defining-Abilities
  end
end
