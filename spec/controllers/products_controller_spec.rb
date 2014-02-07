require 'spec_helper'

describe ProductsController do
  subject { FactoryGirl.create :user }
  let(:user2) { FactoryGirl.create :user }

  before(:each) { sign_in subject }

  describe 'GET #index' do

    context "with my profile" do
      it "render_template index" do
        get :index, profile_id: subject.slug
        response.should render_template 'index'
      end
    end
  end

  describe 'GET #new' do

    context "with my profile" do
      it "assigns a product" do
        get :new, profile_id: subject.slug
        assigns(:product).should_not be_nil
      end

      it "render_template new" do
        get :new, profile_id: subject.slug
        response.should render_template 'new'
      end
    end
  end

  describe 'POST #create' do

    context "with my profile" do
      let(:category) { FactoryGirl.create :category }

      context "with correct params" do

        it "create a product" do
          post :create, profile_id: subject.slug, product: {"name" => "test", "description" => "Great product for a golden test", "category_id" => category.id }
          expect(response).to redirect_to product_path(Product.last.slug)
        end

        it 'assigns product' do
          post :create, profile_id: subject.slug, product: {"name" => "test", "description" => "Great product for a golden test", "category_id" => category.id }
          expect(assigns(:product)).to eq(Product.last)
        end
      end

      context "with incorrect params" do
        it "doesn't create a product without a name" do
          expect {
            post :create, profile_id: subject.slug, product: {"name" => "", "description" => "Great product for a golden test" }
          }.to change{ Product.count }.by(0)
        end

        it "doesn't create a product with a more than 140char description" do
          expect {
            post :create, profile_id: subject.slug, product: {"name" => "test", "description" => "Long string"*1000 }
          }.to change{ Product.count }.by(0)
        end
      end
    end
  end

  describe 'GET #show' do
    let(:product) { FactoryGirl.create :product, user_id: subject.id}
    let(:user2) { FactoryGirl.create :user }

    it 'return 200' do
      get :show, { id: product.slug }
      expect(response.code).to eq('200')
    end

    it 'assign product' do
      get :show, { id: product.slug }
      expect(assigns(:product)).to eq(product)
    end

    it 'assign message to nil' do
      get :show, { id: product.slug }
      expect(assigns(:message)).to eq(nil)
    end
    
    context 'with already a conversation' do

      context 'when the current user is not the owner' do
        let(:product) { FactoryGirl.create :product, user_id: user2.id}
        let(:message) { FactoryGirl.create :message, sender_id: subject.id, receiver_id: user2.id, product_id: product.id }

        it 'assign message with the message' do
          message
          get :show, { id: product.slug }
          expect(assigns(:message)).to eq(message)
        end
      end
    end
  end


  describe 'GET #edit' do
    let(:product) { FactoryGirl.create :product, user_id: subject.id}
    let(:product2) { FactoryGirl.create :product, user_id: user2.id}

    context 'edit my product' do
      it 'return 200' do
        get :edit, { id: product.slug }
        expect(response.code).to eq('200')
      end

      it 'assign product' do
        get :edit, { id: product.slug }
        expect(assigns(:product)).to eq(product)
      end

      it 'render edit template' do
        get :edit, { id: product.slug }
        response.should render_template 'products/edit'
      end
    end

    context 'edit product from other' do
      it 'redirect if trying to edit somebody else product' do
        get :edit, { id: product2.slug }
        expect(response).to redirect_to forbidden_path
      end
    end
  end

  describe 'PUT #update' do
    let(:product) { FactoryGirl.create :product, user_id: subject.id}
    let(:product2) { FactoryGirl.create :product, user_id: user2.id}

    context 'update my product' do
      context 'with correct parameters' do
        it 'update product' do
          put :update, { id: product.id, product: {name: "Great thing", description: "SO Great!"} }
          product.reload
          product.name.should == "Great thing"
          product.slug.should == "great-thing"
        end

        it 'assign product' do
          put :update, { id: product.id, product: {name: "Great thing", description: "SO Great!"} }
          expect(assigns(:product)).to eq(product)
        end

        it 'redirect_to #show' do
          put :update, { id: product.id, product: {name: "Great thing", description: "SO Great!"} }
          response.should redirect_to edit_product_path(product.reload.slug)
        end
      end

      context 'with incorrect parameters' do
        it "doesn't update without name" do
          put :update, { id: product.id, product: {name:"", description: "SO Great!"} }
          product.reload.name.should == product.name          
        end


        it "doesn't update with a too long description" do
          put :update, { id: product.id, product: {name: "Great thing", description: "1000"*1000 } }
          product.reload.description.should == product.description          
        end


        it "flash an error if assets' limit is reached" do
          Product.any_instance.stub(:has_maximum_upload?).and_return(true)
          put :update, { id: product.id, product: {name: "Great thing", description: "1000" } }
          product.reload.description.should == product.description          
        end
      end
    end
  end


  describe 'DELETE #destroy' do
    let(:product) { FactoryGirl.create :product, owner: subject}
    let(:product2) { FactoryGirl.create :product, owner: user2}

    context 'with my product' do
      it 'destroy the product' do
        product
        delete :destroy, { id: product.id }
        Product.exists?(product.id).should == false
      end

      it 'redirect_to my product' do
        product
        delete :destroy, { id: product.id }
        expect(response).to redirect_to products_path(subject.slug)
      end

      context 'with a failed destroy' do
        it 'flash an error' do
          Product.any_instance.stub(:destroy).and_return(false)
          delete :destroy, { id: product.id }
          flash[:alert].should_not be_nil
        end
      end
    end
  end

  describe '#authorized_upload' do

    it 'raise an error with an unvalid asset' do
      ProductAsset.any_instance.stub(:new).and_return(nil)
      controller.authorized_upload 'test'
    end
  end
end