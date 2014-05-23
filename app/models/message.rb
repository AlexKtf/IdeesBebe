# == Schema Information
#
# Table name: messages
#
#  id          :integer          not null, primary key
#  content     :text
#  created_at  :datetime
#  updated_at  :datetime
#  sender_id   :integer
#  receiver_id :integer
#  status_id   :integer
#

class Message < ActiveRecord::Base
  
  belongs_to :sender, class_name: 'User', foreign_key: :sender_id
  belongs_to :receiver, class_name: 'User', foreign_key: :receiver_id
  belongs_to :status, touch: true

  delegate :product, to: :status

  FIRST_REMINDER_OWNER = 3
  SECOND_REMINDER_OWNER = 7
  
  validates :content, length: { minimum: 2 }, presence: true
  
  before_create :can_communicate?

  after_create ->(message) { Notifier.delay.new_message(message) }
  after_create :reminder_owner, unless: :from_owner?
  after_create :response_time, if: [:from_owner?, :last_is_from_buyer?]
  after_create :touch

  def can_communicate?
    status.can_send_message? sender    
  end

  def from_owner?
    status.product.owner == sender
  end

  def need_to_remember?
    status.last_message == self and not product.selled? and not status.closed
  end

  private

    def last_is_from_buyer?
      not status.messages.where('messages.id != ?', id).order('created_at DESC').first.try(:from_owner?)
    end

    # Response time for owner

    def response_time
      owner_msg = status.messages.where(sender_id: sender_id).where('messages.id != ?', id).maximum(:created_at)
      query = Message.joins(:status)
        .where('messages.status_id = ?', status_id)
        .where('messages.receiver_id = ?', sender_id)
      query = query.where('messages.created_at > ?', owner_msg) if not owner_msg.nil?

      query = query.minimum(:created_at)

      time = sender.response_time + (created_at.to_i - query.to_i)
      sender.update_attributes!(response_time: time)
    end

    # Reminder for owner

    def reminder_owner
      Notifier.delay(run_at: created_at + FIRST_REMINDER_OWNER.days).reminder_owner(self, FIRST_REMINDER_OWNER)
      Notifier.delay(run_at: created_at + SECOND_REMINDER_OWNER.days).reminder_owner(self, SECOND_REMINDER_OWNER)
    end
end
