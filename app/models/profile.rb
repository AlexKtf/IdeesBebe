class Profile < ActiveRecord::Base
  
  belongs_to :user
  has_one :avatar, class_name: "Asset", as: :referencer, dependent: :destroy
  accepts_nested_attributes_for :avatar, reject_if: :has_avatar?


  validates :first_name, :last_name, format: { with: /\A[a-zA-Z]+\z/ }, allow_blank: true

  private
    def has_avatar?
      self.avatar.nil? ? false : true
    end
end
