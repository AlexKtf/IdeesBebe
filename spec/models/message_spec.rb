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

require 'spec_helper'

describe Message, :focus do
  let(:product) { create :product, owner: user }
  let(:user) { create :user, response_time: 0 }
  let(:user2) { create :user, response_time: 0 }
  let(:status) { create :status, user_id: user2.id, product: product }
  subject { create :message, sender_id: user2.id, status: status, receiver_id: user.id, content: 'test'}

  describe 'when creates a message' do

    context 'when sender does not have response after 30 minutes' do

      it 'sends a new_messages email' do
        subject
        Timecop.travel(subject.created_at + 30.minutes) do
          Delayed::Worker.new.work_off
          deliveries_with_subject(I18n.t('notifier.new_message_for.subject')).count.should == 1
        end
      end
    end


    context 'when the sender is the owner of the product' do
      let(:message) { create :message, sender_id: user2.id, status: status, receiver_id: user.id, content: 'test' }
      subject { create :message, sender_id: user.id, status: status, receiver_id: user2.id, content: 'test', created_at: message.created_at + 1.days }

      it 'sets the new average response time to the sender' do
        message
        subject.update_attributes!(created_at: message.created_at + 1.days)
        user.reload.response_time.should == 86400
      end

      context 'with three messages for 2 products' do

        let(:product2) { create :product, owner: user, name: 'Test1' }
        let(:status2) { create :status, user_id: user2.id, product: product2 }
        subject { create :message, sender_id: user.id, status: status, receiver_id: user2.id, content: 'test', created_at: message.created_at + 1.days }
        let(:message2) { create :message, sender_id: user2.id, status: status2, receiver_id: user.id, content: 'test', created_at: message.created_at + 2.days }
        let(:message3) { create :message, sender_id: user.id, status: status2, receiver_id: user2.id, content: 'test', created_at:  message.created_at + 4.days }
        let(:message4) { create :message, sender_id: user2.id, status: status2, receiver_id: user.id, content: 'test', created_at: message.created_at + 6.days }
        let(:message5) { create :message, sender_id: user.id, status: status2, receiver_id: user2.id, content: 'test', created_at: message.created_at + 6.days + 45.minutes }

        it 'sets correctly the new average response time to the sender' do
          message
          subject
          message2
          message3
          message4
          message5
          user.reload.response_time.should == 261900
        end
      end
    end
  end

  describe 'Reminder mail' do

    it 'sends an email after 3 days' do
      subject
      Timecop.travel(subject.created_at + 3.days + 10.minutes) do
        Delayed::Worker.new.work_off
        deliveries_with_subject(I18n.t('notifier.reminder_3_days.subject')).count.should == 1
      end
    end

    context 'when the receiver has respond before 3 days'  do
      let(:message) { create :message, sender_id: user.id, status: status, receiver_id: user2.id, created_at: subject.created_at + 1.days, content: 'test'}
      let(:status) { create :status, user_id: user2.id, product: product }

      it 'does not send an email' do
        subject
        message
        Timecop.travel(subject.created_at + 3.days + 10.minutes) do
          Delayed::Worker.new.work_off
          deliveries_with_subject(I18n.t('notifier.reminder_3_days.subject')).count.should == 0
        end
      end
    end

    context 'when the owner has closed the status before 3 days'  do
      let(:status) { create :status, user_id: user2.id, product: product }

      it 'does not send an email' do
        subject
        status.update_attributes!(closed: true)
        Timecop.travel(subject.created_at + 3.days + 10.minutes) do
          Delayed::Worker.new.work_off
          deliveries_with_subject(I18n.t('notifier.reminder_3_days.subject')).count.should == 0
        end
      end
    end
  end

  describe '#from_owner?' do

    context 'when the sender is not the owner of the product' do

      it 'returns false' do
        subject.from_owner?.should == false
      end
    end

    context 'when the sender is the owner of the product' do
      let(:status) { create :status, user_id: user2.id, product: product }
      let(:message) { create :message, sender_id: user.id, status: status, receiver_id: user2.id, content: 'test'}

      it 'returns true' do
        subject
        message.from_owner?.should == true
      end
    end
  end
end
