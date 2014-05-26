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
#  price       :integer          default(0)
#  selled      :boolean          default(FALSE)
#  allowed     :boolean
#

class Product < ActiveRecord::Base

  include Slugable

  enum state: [:avalaible, :selled, :disallowed]

  MAXIMUM_UPLOAD_PHOTO = 2

  belongs_to :owner, foreign_key: 'user_id', class_name: 'User'
  belongs_to :category

  has_many :photos, dependent: :destroy
  has_many :status
  has_many :messages, through: :status
  has_many :reports, dependent: :destroy

  accepts_nested_attributes_for :category

  validates :name, length: { minimum: 5, maximum: 60 }, format: { with: /\A[[:digit:][:alpha:]\s'\-_]*\z/u }
  validates :price, numericality: { only_integer: true, greater_than: 0 }, length: { minimum: 1, maximum: 9 }
  validates :category_id, presence: true
  validates :dpt, length: { minimum:2, maximum: 3 }
  validate :valid_dep


  before_save :to_slug, if: :name_changed?

  paginates_per 24

  def slug
    "#{id}-#{super}"
  end

  def selled_to
    status.where(done: true).first.try(:user)
  end

  def pending_status_for_owner
    status.reject{ |stat| stat.last_message.from_owner? or stat.closed or stat.product.selled? }
  end

  def dep
    I18n.t("dptment.dep_#{dpt}")
  end

  def valid_dep
    vd = (1..96).to_a + (971..974).to_a
    if not ['2A', '2B'].include?(dpt.upcase) or not vd.include?(dpt.to_i)
      errors.add(:dpt, :invalid_dep)
    end
  end
end
