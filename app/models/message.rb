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

  REMINDER_AFTER = 3
  
  validates :content, length: { minimum: 2 }, presence: true

  after_create ->(message) { delay(run_at: message.created_at + 30.minutes).reminder }
  after_create :check_active_reminder
  after_create :response_time, if: [:from_owner?, :last_is_from_buyer?]
  after_create :touch

  def from_owner?
    status.product.owner == sender
  end

  def need_to_remember?
    return false if not product.avalaible? or status.closed
    status.messages.where(sender_id: receiver_id).where('messages.created_at > ?', self.created_at).count.zero?
  end

  private

    # Email reminder

    def reminder
      messages = status.messages.where('messages.created_at > ?', created_at)
      Notifier.new_message_for(receiver, self).deliver if messages.count.zero?
    end

    def check_active_reminder
      return if Delayed::Job.where(queue: "reminder_#{receiver_id}_#{status_id}").any?
      delay(queue: "reminder_#{receiver_id}_#{status_id}", run_at: created_at + 3.days).late_reminder
    end

    def late_reminder
      messages = status.messages.where(sender_id: receiver_id).where('messages.created_at > ?', created_at)
      Notifier.reminder((messages.order('created_at DESC').first || self), REMINDER_AFTER).deliver if messages.count.zero?
    end

    # Response time for owner

    def last_is_from_buyer?
      not status.messages.where('messages.id != ?', id).order('created_at DESC').first.try(:from_owner?)
    end

    def response_time
      owner_msg = status.messages.where(sender_id: sender_id).where('messages.id != ?', id).maximum(:created_at)
      query = status.messages.where(receiver_id: sender_id)
      query = query.where('messages.created_at > ?', owner_msg) if not owner_msg.nil?

      query = query.minimum(:created_at)

      time = sender.response_time + (created_at.to_i - query.to_i)
      sender.update_attributes!(response_time: time)
    end
end
