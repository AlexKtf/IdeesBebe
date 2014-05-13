require 'spec_helper'

describe MessagesController do

  let(:product) { create :product, owner: user }
  let(:user) { create :user }
  let(:user2) { create :user }
  let(:user3) { create :user }

  subject { create :message }
  
  before(:each) do
    sign_in user
  end

  describe '#index' do
    let(:product2) { create :product, owner: user, state: 1 }
    let(:message) { create :message, status: status, sender_id: user2.id, receiver_id: user.id }
    let(:message2) { create :message, status: status, sender_id: user.id, receiver_id: user2.id }
    let(:message3) { create :message, status: status2, sender_id: user3.id, receiver_id: user.id }
    let(:status) { create :status, product_id: product.id, user_id: user2.id }
    let(:status2) { create :status, product_id: product2.id, user_id: user3.id, done: true }

    it 'assigns status' do
      message
      message2
      message3
      get :index, profile_id: user.slug
      assigns(:status).should == [status2, status]
    end

    context 'with parameters pending messages' do

      it 'assigns status' do
        message
        message3
        get :index, profile_id: user.slug, state: 'pending'
        assigns(:status).should == [status]
      end
    end

    context 'with parameters archived messages' do

      it 'assigns status' do
        message
        message2
        message3
        get :index, profile_id: user.slug, state: 'archived'
        assigns(:status).should == [status2]
      end
    end

    context 'with messagesbox from another' do

      it 'redirect to forbidden' do
        message
        message2
        message3
        get :index, profile_id: user2.slug
        response.should redirect_to forbidden_path
      end
    end
  end

  describe '#create' do

    context 'without a status between owner and buyer' do

      it 'creates the status' do
        expect {
          post :create, product_id: product.id, message: { receiver_id: user.id, content: 'test' }
        }.to change{ Status.count }.by 1
      end
    end

    it 'creates the message' do
      expect {
        post :create, product_id: product.id, message: { receiver_id: user.id, content: 'test' }
      }.to change{ Message.count }.by 1
    end

    it 'redirect to the product page' do
      post :create, product_id: product.id, message: { receiver_id: user.id, content: 'test' }
      response.should redirect_to product_path(product.slug)
    end

    context 'with an incorrect message' do

      it 'raise an error' do
        post :create, product_id: product.id, message: { sender_id: user2.id, content: '' }
        flash[:alert].should_not be_nil
      end
    end

    context 'with a failed create' do

      it 'raise an error' do
        Message.any_instance.stub(:save).and_return(false)
        post :create, product_id: product.id, message: { sender_id: user2.id, content: 'test' }
        flash[:alert].should_not be_nil
      end
    end
  end
end
