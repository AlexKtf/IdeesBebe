require 'spec_helper'

describe ProductsController do
  subject { FactoryGirl.create :user }
  let(:user2) { FactoryGirl.create :user }

  before(:each) { sign_in subject }

  describe 'GET #index' do

    context "with my profile" do
      it "show all products" do
        get :index, profile_id: subject.slug
        expect(assigns(:products)).to eq(subject.products)
      end

      it "render_template index" do
        get :index, profile_id: subject.slug
        response.should render_template 'index'
      end
    end
  end

  describe 'GET #new' do

    context "with my profile" do
      it "authorize to create a product" do
        get :new, profile_id: subject.slug
        expect(assigns(:user)).to eq(subject)
      end

      it "render_template new" do
        get :new, profile_id: subject.slug
        response.should render_template 'new'
      end
    end
  end

  describe 'POST #create' do

    context "with my profile" do

      context "with correct params" do
        it "create a product" do
          post :create, profile_id: subject.slug, product: {"name" => "test", "description" => "Great product for a golden test" }
          expect(response).to redirect_to product_path(Product.last.slug)
          expect(assigns(:user)).to eq(subject)
        end
      end

      context "with incorrect params" do
        it "doesn't create a product without name" do
          expect {
            post :create, profile_id: subject.slug, product: {"name" => "", "description" => "Great product for a golden test" }
          }.to change{ Product.count }.by(0)
        end

        it "doesn't create a product without a more than 140char description" do
          expect {
            post :create, profile_id: subject.slug, product: {"name" => "test", "description" => "Long string"*1000 }
          }.to change{ Product.count }.by(0)
        end

        it 'assigns user' do
          expect {
            post :create, profile_id: subject.slug, product: {"name" => "test", "description" => "Long string"*1000 }
          }.to change{ Product.count }.by(0)

          expect(assigns(:user)).to eq(subject)
        end
      end
    end
  end

  describe 'GET #show' do
    let(:product) { FactoryGirl.create :product, user_id: subject.id}
    it 'return 200 with slug' do
      get :show, { id: product.slug }
      expect(assigns(:user)).to eq(subject)
      expect(response.code).to eq('200')
    end

    it 'return 200 with id' do
      get :show, { id: product.id }
      expect(assigns(:user)).to eq(subject)
      expect(response.code).to eq('200')
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
        get :edit, { id: product2.id }
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
          put :update, { id: product.slug, product: {"name" => "Great thing", description: "SO Great!"} }
          product.reload
          product.name.should == "Great thing"
          product.slug.should == "Great_thing"
        end

        it 'assign product' do
          put :update, { id: product.slug, product: {"name" => "Great thing", description: "SO Great!"} }
          expect(assigns(:product)).to eq(product)
        end

        it 'redirect_to #show' do
          put :update, { id: product.slug, product: {"name" => "Great thing", description: "SO Great!"} }
          response.should redirect_to product_path(product.reload.slug)
        end
      end

      context 'with incorrect parameters' do
        it "doesn't update without name" do
          put :update, { id: product.slug, product: {"name" => "", description: "SO Great!"} }
          product.reload.name.should == product.name          
        end


        it "doesn't update with a too long description" do
          put :update, { id: product.slug, product: {"name" => "Great thing", description: "1000"*1000 } }
          product.reload.description.should == product.description          
        end
      end
    end

    context 'update product from other' do
      it 'redirect if trying to update somebody else product' do
        get :edit, { id: product2.id }
        expect(response).to redirect_to forbidden_path
      end
    end
  end


  describe 'DELETE #destroy' do
    let(:product) { FactoryGirl.create :product, user_id: subject.id}
    let(:product2) { FactoryGirl.create :product, user_id: user2.id}

    context 'update my product' do
      it 'destroy the product' do
        delete :destroy, { id: product.id }
        Product.exists?(product.id).should == nil
      end

      it 'redirect_to my profile' do
        delete :destroy, { id: product.id }
        expect(response).to redirect_to profile_path(subject.slug)
      end

      it 'assigns user' do
        delete :destroy, { id: product.id }
        expect(assigns(:user)).to eq(subject)
      end
    end

    context 'destroy product from other' do
      it 'redirect if trying to destroy somebody else product' do
        delete :destroy, { id: product2.id }
        expect(response).to redirect_to forbidden_path
      end
    end
  end
end