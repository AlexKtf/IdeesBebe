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
#  active      :boolean          default(TRUE)
#  price       :integer          default(0)
#  selled      :boolean          default(FALSE)
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
  end


  describe '#starred_asset' do

    context 'with photos' do
      let(:asset) { FactoryGirl.create :photo, product: subject, starred: true }

      it 'return the starred asset' do
        asset
        subject.starred_asset.model.id.should == asset.id
      end
    end

    context 'with no photos' do

      it 'return nil' do
        subject.starred_asset.should == nil
      end
    end
  end

  describe '#has_maximum_upload?' do

    context 'with already too many photos' do
      let(:asset) { FactoryGirl.create :photo, product: subject }
      let(:asset2) { FactoryGirl.create :photo, product: subject }

      it 'return true' do
        asset
        asset2
        subject.has_maximum_upload?.should == true
      end
    end

    context 'without too many photos' do

      it 'return false' do
        subject.has_maximum_upload?.should == false
      end
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
