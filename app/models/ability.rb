class Ability
  include CanCan::Ability

  def initialize(user)

    unless user.nil?
          
      can :manage, [Profile, Product], user_id: user.id

      can [:destroy, :update], ProductAsset do |asset|
        user.products.map(&:id).include?(asset.product.id)
      end
      can :destroy, Comment, user_id: user.id
      can :destroy, User, id: user.id

      can :create, Comment
      can :create, Message

      can :index, Message
    end

    can :show, :all
    can :show_subcategory, Category
    can :index, Product
  end
end
