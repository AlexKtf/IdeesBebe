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

require 'spec_helper'

describe Product do
  it_behaves_like Slugable do
    subject { FactoryGirl.create :product, name: "momé dad hOme" }
  end

  subject { FactoryGirl.create :product }

  context 'when create' do
    it 'fails without name' do
      FactoryGirl.build(:product, name: "").should_not be_valid
    end

    it 'fails if the name is already taken' do
      FactoryGirl.build(:product, name: subject.name).should_not be_valid
    end

    it 'fails if the description is too long' do
      FactoryGirl.build(:product, description: "1000"*1000).should_not be_valid
    end
  end


  describe '#starred_asset' do

    context 'with assets' do
      let(:asset) { FactoryGirl.create :product_asset, product: subject, starred: true }

      it 'return the starred asset' do
        asset
        subject.starred_asset.model.id.should == asset.id
      end
    end

    context 'with no assets' do

      it 'return nil' do
        subject.starred_asset.should == nil
      end
    end
  end

  describe '#has_maximum_upload?' do

    context 'with already too many assets' do
      let(:asset) { FactoryGirl.create :product_asset, product: subject }
      let(:asset2) { FactoryGirl.create :product_asset, product: subject }

      it 'return true' do
        asset
        asset2
        subject.has_maximum_upload?.should == true
      end
    end

    context 'without too many assets' do

      it 'return false' do
        subject.has_maximum_upload?.should == false
      end
    end
  end


  describe '#last_message_with' do
    let(:user2) { FactoryGirl.create :user }
    let(:user) { FactoryGirl.create :user }
    subject { FactoryGirl.create :product, user: user2 }

    it 'returns nil' do
      user
      subject.last_message_with(user).should == nil
    end

    context 'with two messages' do
      let(:msg) { FactoryGirl.create :message,  sender: user, receiver: user2, product: subject, content: 'test2' }
      let(:msg2) { FactoryGirl.create :message,  sender: user, receiver: user2, product: subject, content: 'test1' }

      it 'returns the newest' do
        subject
        msg
        msg2
        subject.last_message_with(user).content.should == msg2.content
      end
    end
  end


  describe '#seller_pending_messages_count' do
    let(:user2) { FactoryGirl.create :user }
    let(:user) { FactoryGirl.create :user }
    subject { FactoryGirl.create :product, user: user2 }

    it 'returns 0' do
      user
      subject.seller_pending_messages_count.should == 0
    end

    context 'with two messages' do
      let(:user3) { FactoryGirl.create :user }
      let(:msg) { FactoryGirl.create :message,  sender: user, receiver: user2, product: subject, content: 'test2' }
      let(:msg2) { FactoryGirl.create :message,  sender: user3, receiver: user2, product: subject, content: 'test1' }
      let(:msg3) { FactoryGirl.create :message,  sender: user3, receiver: user2, product: subject, content: 'test13' }

      it 'returns 2' do
        subject
        msg
        msg2
        msg3
        subject.seller_pending_messages_count.should == 2
      end
    end

    context 'with one message which has already been respond' do
      let(:msg) { FactoryGirl.create :message,  sender: user, receiver: user2, product: subject, content: 'test2' }
      let(:msg2) { FactoryGirl.create :message,  sender: user2, receiver: user, product: subject, content: 'test1' }

      it 'returns 0' do
        subject
        msg
        msg2
        subject.seller_pending_messages_count.should == 0
      end
    end
  end
end
