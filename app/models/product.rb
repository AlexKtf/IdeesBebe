# == Schema Information
#
# Table name: products
#
#  id          :integer          not null, primary key
#  name        :string(255)
#  slug        :string(255)
#  description :text
#  created_at  :datetime
#  updated_at  :datetime
#  user_id     :integer
#  category_id :integer
#

class Product < ActiveRecord::Base

  include Slugable

  MAXIMUM_UPLOAD_PHOTO = 2

  belongs_to :user
  belongs_to :category

  has_many :assets, foreign_key: 'product_id', class_name: 'ProductAsset', dependent: :destroy
  has_many :comments, dependent: :destroy
  has_many :messages, dependent: :destroy

  accepts_nested_attributes_for :category

  validates :name,
    length: {
      minimum: 2,
      maximum: 60,
      message: I18n.t('product.name.length')
    },
    uniqueness: {
      case_sensitive: false,
      message: I18n.t('product.name.uniqueness')
    },
    format: {
      with: /\A[[:digit:][:alpha:]\s'\-_]*\z/u,
      message: I18n.t('product.name.format')
    }

  validates :description,
    length: {
      maximum: 140,
      message: I18n.t('product.description.length')
    },
    allow_blank: true

  validates :category_id, presence: { message: I18n.t('product.category.presence') }

  before_save :to_slug, if: :name_changed?

  def starred_asset
    assets.where(starred: true).first.try(:file)
  end

  def has_maximum_upload?
    assets.count == MAXIMUM_UPLOAD_PHOTO
  end

  def last_message_with user
    messages.where('sender_id = ? OR receiver_id = ?', user.id, user.id).order('created_at DESC').limit(1).try(:first)
  end

  def seller_pending_messages_count
    count = 0
    messages.where('sender_id != ?', user.id).pluck(:sender_id).uniq.each do |sender_id|
      count += last_message_with(User.find(sender_id)).from_seller? ? 0 : 1
    end
    count
  end
end
