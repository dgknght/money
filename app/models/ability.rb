class Ability
  include CanCan::Ability

  def initialize(user)
    user ||= User.new
    
    can :manage, Entity, user_id: user.id
    can :manage, Account do |account|
      user.entities.include? account.entity
    end
    can :manage, Transaction do |transaction|
      user.entities.include? transaction.entity
    end
    can :manage, TransactionItem do |transaction_item|
      user.entities.include? transaction_item.transaction.entity
    end
    can :manage, Attachment do |attachment|
      user.entities.include? attachment.transaction.entity
    end
    can :manage, Budget do |budget|
      user.entities.include? budget.entity
    end
    can :manage, BudgetItem do |budget_item|
      user.entities.include? budget_item.budget.entity
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
