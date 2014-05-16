# == Schema Information
#
# Table name: users
#
#  id                     :integer          not null, primary key
#  email                  :string(255)      default(""), not null
#  encrypted_password     :string(255)      default(""), not null
#  reset_password_token   :string(255)
#  reset_password_sent_at :datetime
#  remember_created_at    :datetime
#  sign_in_count          :integer          default(0), not null
#  current_sign_in_at     :datetime
#  last_sign_in_at        :datetime
#  current_sign_in_ip     :string(255)
#  last_sign_in_ip        :string(255)
#  created_at             :datetime
#  updated_at             :datetime
#  username               :string(255)
#  slug                   :string(255)
#  response_time          :integer          default(0)
#  provider               :string(255)
#  fb_id                  :string(255)
#  fb_tk                  :string(255)
#  is_admin               :boolean          default(FALSE)
#

class User < ActiveRecord::Base

  include Slugable

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable, :omniauthable, omniauth_providers: [:facebook]

  validates :username,
    length: { minimum: 2 },
    presence: true,
    uniqueness: { case_sensitive: false },
    format: { with: /\A[[:digit:][:alpha:]\s'\-_]*\z/u }
  validates :email, presence: true

  has_one :profile, dependent: :destroy

  has_many :products, dependent: :destroy

  has_many :status

  has_many :messages_sent, class_name: 'Message', foreign_key: :sender_id
  has_many :messages_received, class_name: 'Message', foreign_key: :receiver_id

  has_many :reports, dependent: :destroy

  attr_accessor :login


  after_create :create_profile!
  after_create ->(user) { Notifier.delay.welcome(user) }

  before_save :to_slug, if: :username_changed?

  def avatar
    profile.avatar
  end

  def average_response_time
    messages_sent.count > 0 ? response_time/messages_sent.count : response_time
  end

  def is_owner_of? product
    product.user_id == self.id
  end

  def conversations
    Status.joins(:user).joins(:product).where('products.user_id = ? OR statuses.user_id = ?', id, id).group('statuses.id')
  end

  def satisfaction_rating
    statuses = Status.joins(:product).where('products.user_id = ? AND (statuses.satisfied = ? OR statuses.satisfied = ?)', id, true, false)
    return if statuses.count.zero?
    (statuses.where('statuses.satisfied = ?', true).count * 100) / statuses.count
  end

  class << self

    def find_first_by_auth_conditions warden_conditions
      conditions = warden_conditions.dup
      if login = conditions.delete(:login)
        where(conditions).where(['lower(username) = :value OR lower(email) = :value', { value: login.downcase }]).first
      else
        where(conditions).first
      end
    end

    def find_for_facebook_oauth(auth, signed_in_resource = nil)
      user = User.where('email = ? OR (provider = ? AND fb_id = ?)', auth.info.email, auth.provider, auth.uid).first
      return user if user.present?
      @user = User.create!(username:auth.info.name.strip, provider:auth.provider, fb_id:auth.uid, email:auth.info.email, fb_tk:auth.credentials.token, password:Devise.friendly_token[0,20])
    end
  end
end
