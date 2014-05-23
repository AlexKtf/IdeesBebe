require 'spec_helper'

describe PhotosController do
  let(:user) { FactoryGirl.create :user }
  let(:user2) { FactoryGirl.create :user }
  let(:product) { FactoryGirl.create :product, user_id: user.id}
  let(:product2) { FactoryGirl.create :product, user_id: user2.id}


  before(:each) { sign_in user }

  describe 'POST #create' do
  
    context 'with my product' do
      it 'create photo' do
        Photo.any_instance.stub(:file?).and_return(true)
        Photo.any_instance.stub(:valid?).and_return(true)
        product
        expect {
          post :create, { product_id: product, photo: { file: 'test' } }
        }.to change{Photo.count}.by 1
      end

      it 'redirect to #edit' do
        product
        post :create, { product_id: product.id, photo: { file: 'test' } }
        response.should redirect_to edit_product_path(product.slug)
      end

      context 'with a failed create' do
        it 'flash an error' do
          Photo.any_instance.stub(:save).and_return(false)
          product
          post :create, { product_id: product.id, photo: { file: 'test' } }
          flash[:alert].should_not be_nil
        end
      end

      context 'without file' do
        it 'flash an alert' do
          product
          post :create, { product_id: product.id, photo: { file: ''} }
          flash[:alert].should_not be_nil
        end
      end
    end

    context 'with product from other' do
      it 'redirect to forbidden' do
        post :create, { product_id: product2.id, photo: { file: 'test' } }
        response.should redirect_to forbidden_path
      end
    end
  end

  describe 'DELETE #destroy' do
  
    context 'for the product photos' do
      let(:photo2) { FactoryGirl.create :photo, product: product2 }
      let(:photo3) { FactoryGirl.create :photo, product: product }
      subject { FactoryGirl.create :photo, product: product }

      context 'with my product' do
        it 'destroys photo' do
          photo3
          subject
          delete :destroy, { id: subject }
          Photo.exists?(subject).should == false        
        end

        it 'redirect to #edit' do
          photo3
          subject
          delete :destroy, { id: subject.id }
          response.should redirect_to edit_product_path(product.slug)
        end

        context 'with a failed destroy' do
          it 'flash an error' do
            Photo.any_instance.stub(:destroy).and_return(false)
            subject
            delete :destroy, { id: subject.id }
            flash[:alert].should_not be_nil
          end
        end
      end

      context 'with product from other' do
        it 'redirect to forbidden' do
          delete :destroy, { id: photo2.id }
          response.should redirect_to forbidden_path
        end
      end
    end
  end
end