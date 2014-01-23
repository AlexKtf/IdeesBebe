# == Schema Information
#
# Table name: messages
#
#  id         :integer          not null, primary key
#  content    :text
#  user_id    :integer
#  product_id :integer
#  created_at :datetime
#  updated_at :datetime
#

class Message < ActiveRecord::Base
  belongs_to :user
  belongs_to :product

  validates :content,
    length: {
      minimum: 2,
      maximum: 250,
      message: I18n.t('comment.content.length')
    },
    presence: { message: I18n.t('comment.content.presence') }

  after_create ->(message) { Notifier.delay.new_message(message) }
end
