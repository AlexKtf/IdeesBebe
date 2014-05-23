class Ability
  include CanCan::Ability

  def initialize user

    unless user.nil?
      can :manage, [Profile, Product], user_id: user.id

      can [:destroy, :update], Photo, product: { user_id: user.id }
      can :destroy, User, id: user.id

      can :create, Message
      can :read, Message
      
      can :create, Report
      cannot :create, Report do |report|
        user.reports.where(product_id: report.product_id).count > 0
      end

      can :show, Status do |status|
        user.is_owner_of?(status.product) or status.user.id == user.id
      end
      can :update, Status, product: { user_id: user.id }
    end

    can :show, :all
    can :show_subcategory, Category
    can :index, Product
  end
end
