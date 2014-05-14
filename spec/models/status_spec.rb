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

require 'spec_helper'

describe Status do

  describe 'when updates' do
    let(:product) { create :product, owner: user }
    let(:user) { create :user, response_time: 0 }
    let(:user2) { create :user, response_time: 0 }
    let(:user3) { create :user, response_time: 0 }
    subject { create :status, user_id: user2.id, product: product }
    let(:status2) { create :status, user_id: user3.id, product: product }
    let(:message) { create :message, sender_id: user2.id, status: subject, receiver_id: user.id, content: 'test'}
    let(:message2) { create :message, sender_id: user3.id, status: status2, receiver_id: user.id, content: 'test'}

    context 'when the selling the product' do
      
      it 'mark the product as selled' do
        message
        subject.update_attributes!(done: true)
        subject.product.reload.selled?.should == true
      end

      it 'sends an email to the buyer' do
        message
        message2
        expect {
          subject.update_attributes!(done: true)
          Delayed::Worker.new.work_off
        }.to change{deliveries_with_subject(I18n.t('notifier.signalized_as_buyer.subject', product: product.name)).count}.by 1
      end

      it 'sends an email to the other buyer' do
        message
        message2
        expect {
          subject.update_attributes!(done: true)
          Delayed::Worker.new.work_off
        }.to change{deliveries_with_subject(I18n.t('notifier.product_not_available_anymore.subject', product: product.name)).count}.by 1
      end
    end
  end
end
