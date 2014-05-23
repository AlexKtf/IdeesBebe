# == Schema Information
#
# Table name: statuses
#
#  id         :integer          not null, primary key
#  product_id :integer
#  user_id    :integer
#  closed     :boolean
#  done       :boolean
#  created_at :datetime
#  updated_at :datetime
#  satisfied  :boolean
#

class Status < ActiveRecord::Base
  belongs_to :product
  belongs_to :user
  has_many :messages

  MESSAGE_LIMIT_STRAIGHT = 50

  after_update :mark_product_as_selled, if: [:done_changed?, :done]

  scope :pending, ->(user) { where('products.state = ?', 0).reject{ |status| status.last_message.sender_id == user.id or status.closed } }
  scope :archived, ->() { select{ |status| status.closed or status.product.selled? } }

  def mark_product_as_selled
    product.selled!
    Notifier.delay.signalized_as_buyer(user, product)
    others = User.joins(:status)
              .where('statuses.product_id = ? AND users.id != ?', product_id, user_id)
              .pluck(:email)
    Notifier.delay.product_not_available_anymore(others, product)
  end

  def pending_messages_count
    date = messages.where(sender_id: product.user_id).maximum(:created_at) || DateTime.new
    messages.where(sender_id: user_id).where('messages.created_at > ?', date).count
  end

  def can_send_message? user
    return false if closed or product.selled?
    messages.order('created_at DESC').limit(MESSAGE_LIMIT_STRAIGHT).reject{ |msg| msg.sender_id != user.id }.count < MESSAGE_LIMIT_STRAIGHT
  end

  def last_message
    messages.order('messages.created_at DESC').first
  end
end
