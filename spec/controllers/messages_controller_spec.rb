require 'spec_helper'

describe MessagesController do

  let(:product) { FactoryGirl.create :product, owner: user }
  let(:user) { FactoryGirl.create :user }
  let(:user2) { FactoryGirl.create :user }
  let(:user3) { FactoryGirl.create :user }
  subject { FactoryGirl.create :message }
  
  before(:each) do
    sign_in user
  end

  describe '#index' do
    let(:message) { FactoryGirl.create :message, product_id: product.id, sender_id: user2.id, receiver_id: user.id }
    let(:message2) { FactoryGirl.create :message, product_id: product.id, sender_id: user.id, receiver_id: user2.id }
    let(:message3) { FactoryGirl.create :message, product_id: product.id, sender_id: user3.id, receiver_id: user.id }

    it 'assigns @messages' do
      message
      message2
      message3
      get :index, product_id: product.slug
      assigns(:messages).should == [message2, message3]
    end
  end


  describe '#show' do
    let(:message) { FactoryGirl.create :message, product_id: product.id, sender_id: user2.id, receiver_id: user.id }
    let(:message2) { FactoryGirl.create :message, product_id: product.id, sender_id: user.id, receiver_id: user2.id }
    let(:message3) { FactoryGirl.create :message, product_id: product.id, sender_id: user3.id, receiver_id: user.id }

    it 'assigns @messages' do
      message
      message2
      message3
      get :show, product_id: product.slug, id: user2.slug
      assigns(:messages).should == [message, message2]
    end

    it 'assigns @last_message' do
      message
      message2
      message3
      get :show, product_id: product.slug, id: user2.slug
      assigns(:last_message).should == message2
    end
  end

  describe '#create' do

    it 'creates the message' do
      expect {
        post :create, product_id: product.id, message: { sender_id: user2.id, receiver_id: user.id, content: 'test' }
      }.to change{ Message.count }.by 1
    end

    it 'redirect to the product page' do
      post :create, product_id: product.id, message: { sender_id: user2.id, receiver_id: user.id, content: 'test' }
      response.should redirect_to product_path(product.slug)
    end

    context 'with already a conversation' do
      subject { FactoryGirl.create :message, sender_id: user2.id  }
      let(:msg2) { FactoryGirl.create :message, sender_id: user.id  }

      context 'when the seller respond' do

      end
    end

    context 'with an incorrect comment' do

      it 'raise an error' do
        Message.any_instance.stub(:save).and_return(false)
        Message.any_instance.stub(:errors).and_return([:content, "Too short"])
        post :create, product_id: product.id, message: { sender_id: user2.id, content: '' }
        flash[:error].should_not be_nil
      end
    end

    context 'with a failed create' do

      it 'raise an error' do
        Message.any_instance.stub(:save).and_return(false)
        Message.any_instance.stub(:errors).and_return([])
        post :create, product_id: product.id, message: { sender_id: user2.id, content: 'test' }
        flash[:error].should_not be_nil
      end
    end
  end
end