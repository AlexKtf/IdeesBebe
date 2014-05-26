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

require 'spec_helper'

describe Product do
  it_behaves_like Slugable do
    subject { FactoryGirl.create :product, name: "momé dad hOme" }
  end

  subject { FactoryGirl.create :product }

  context 'when create' do
    let(:category) { FactoryGirl.create :category }
    it 'fails without name' do
      FactoryGirl.build(:product, name: "", category_id: category.id).should_not be_valid
    end

    it 'fails without price' do
      FactoryGirl.build(:product, name: "", price: '', category_id: category.id).should_not be_valid
    end

    it 'fails with free product' do
      FactoryGirl.build(:product, name: "", price: 0, category_id: category.id).should_not be_valid
    end

    it 'fails without departement' do
      FactoryGirl.build(:product, dpt: "", category_id: category.id).should_not be_valid
    end
  end

  describe '#pending_status_for_owner' do
    let(:user2) { FactoryGirl.create :user }
    let(:user) { FactoryGirl.create :user }
    subject { FactoryGirl.create :product, owner: user2 }

    it 'returns empty' do
      user
      subject.pending_status_for_owner.should == []
    end

    context 'with two status pending' do
      let(:user3) { FactoryGirl.create :user }
      let(:status) { FactoryGirl.create :status, product_id: subject.id, user_id: user.id }
      let(:status2) { FactoryGirl.create :status, product_id: subject.id, user_id: user3.id }
      let(:msg) { FactoryGirl.create :message, sender_id: user.id, receiver_id: user2.id, content: 'test2', status_id: status.id }
      let(:msg2) { FactoryGirl.create :message, sender_id: user3.id, receiver_id: user2.id, content: 'test1', status_id: status2.id }

      it 'returns 2 status' do
        msg
        msg2
        subject.pending_status_for_owner.should == [status, status2]
      end
    end

    context 'with one message which has already been respond' do
      let(:user3) { FactoryGirl.create :user }
      let(:status) { FactoryGirl.create :status, product_id: subject.id, user_id: user.id }
      let(:status2) { FactoryGirl.create :status, product_id: subject.id, user_id: user3.id }
      let(:msg) { FactoryGirl.create :message, sender_id: user.id, receiver_id: user2.id, content: 'test2', status_id: status.id }
      let(:msg2) { FactoryGirl.create :message, sender_id: user3.id, receiver_id: user2.id, content: 'test1', status_id: status2.id }
      let(:msg3) { FactoryGirl.create :message,  sender_id: user2.id, receiver_id: user3.id, content: 'test2', status_id: status2.id }
      let(:msg4) { FactoryGirl.create :message,  sender_id: user2.id, receiver_id: user.id, content: 'test1', status_id: status.id }

      it 'returns empty' do
        msg
        msg2
        msg3
        msg4
        subject.pending_status_for_owner.should == []
      end
    end
  end
end
