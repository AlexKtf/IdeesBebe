class User < ActiveRecord::Base
  
  include Slugable

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  validates :username,
    length: { minimum: 2, message: I18n.t('user.username.length') },
    presence: { message: I18n.t('user.username.presence')},
    uniqueness: { :case_sensitive => false, message: I18n.t('user.username.uniqueness') },
    format: { with: /\A[[:digit:][:alpha:]\s'\-_]*\z/u, message: I18n.t('user.username.format') }
  validates :email, presence: { message: I18n.t('user.email.presence') }
  
  has_one :profile, dependent: :destroy

  has_many :products, dependent: :destroy  
  has_many :comments, dependent: :destroy

  attr_accessor :login

  
  after_create :create_profile!

  before_save :to_slug, :if => :username_changed?


  def self.find_first_by_auth_conditions(warden_conditions)
    conditions = warden_conditions.dup
    if login = conditions.delete(:login)
      where(conditions).where(["lower(username) = :value OR lower(email) = :value", { :value => login.downcase }]).first
    else
      where(conditions).first
    end
  end

  def avatar
    profile.asset.nil? ? nil : profile.asset.file
  end

  def avatar_id
    profile.asset.id.nil? ? nil : profile.asset.id
  end
end
