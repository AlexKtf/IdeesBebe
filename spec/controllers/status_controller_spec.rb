require 'spec_helper'

describe StatusController do

  let(:product) { FactoryGirl.create :product, owner: user }
  let(:user) { FactoryGirl.create :user }
  let(:user2) { FactoryGirl.create :user }
  let(:user3) { FactoryGirl.create :user }
  let(:message) { FactoryGirl.create :message, status: status2, sender_id: user2.id, receiver_id: user.id }
  let(:message2) { FactoryGirl.create :message, status: status2, sender_id: user.id, receiver_id: user2.id }
  let(:message3) { FactoryGirl.create :message, status: status3, sender_id: user3.id, receiver_id: user.id }
  let(:status2) { FactoryGirl.create :status, product_id: product.id, user_id: user2.id }
  let(:status3) { FactoryGirl.create :status, product_id: product.id, user_id: user3.id }
  
  let(:connect) { sign_in user }


  describe '#update' do
    let(:message3) { FactoryGirl.create :message, status: status3, sender_id: user3.id, receiver_id: user.id }

    context 'when closing a status' do

      it 'closes the status' do
        connect
        message
        put :update, product_id: product.slug, id: user2.slug, status: { closed: true }
        status2.reload.closed.should == true
      end

    end

    context 'when done a status' do

      it 'done the status' do
        connect
        message
        put :update, product_id: product.slug, id: user2.slug, status: { done: true }
        status2.reload.done.should == true
      end

    end

    context 'when reopening a status' do

      it 'opens the status' do
        connect
        message
        put :update, product_id: product.slug, id: user2.slug, status: { closed: false }
        status2.reload.closed.should == false
      end

    end

    it 'redirects to index' do
      connect
      message
      put :update, product_id: product.slug, id: user2.slug, status: { done: true }
      response.should redirect_to product_status_index_path(product.slug)
    end

    context 'with product of another' do

      it 'redirects to forbidden' do
        sign_in user2
        message
        put :update, product_id: product.slug, id: user2.slug, status: { closed: true }
        response.should redirect_to forbidden_path
      end
    end
  end

  describe '#index' do
    let(:message3) { FactoryGirl.create :message, status: status3, sender_id: user3.id, receiver_id: user.id }

    it 'assigns @status' do
      connect
      message
      message2
      message3
      get :index, product_id: product.slug
      assigns(:status).should =~ [status2, status3]
    end

    context 'with product of another' do

      it 'redirects to forbidden' do
        sign_in user2
        message
        message2
        message3
        get :index, product_id: product.slug
        response.should redirect_to forbidden_path
      end
    end
  end

  describe '#show' do

    it 'assigns @messages' do
      connect
      message
      message2
      message3
      get :show, product_id: product.slug, id: user2.slug
      assigns(:messages).should == [message, message2]
    end

    it 'assigns @status' do
      connect
      message
      message2
      message3
      get :show, product_id: product.slug, id: user2.slug
      assigns(:status).should == status2
    end

    context 'with product of another or not the concerned buyer' do
      let(:product) { FactoryGirl.create :product, owner: user2 }

      it 'redirects to forbidden' do
        sign_in user3
        message
        message2
        message3
        get :show, product_id: product.slug, id: user2.slug
        response.should redirect_to forbidden_path
      end
    end
  end
end
