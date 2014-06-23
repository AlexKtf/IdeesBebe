require 'spec_helper'

describe ProductsController do
  subject { create :user }
  let(:user2) { create :user }

  before(:each) { sign_in subject }

  describe 'GET #index' do
    let(:product) { create :product, user_id: subject.id }
    let(:product2) { create :product, user_id: subject.id, name: 'testtest' }
    let(:status) { create :status, product_id: product2.id, user_id: user2.id, done: true }

    it 'assigns products' do
      product
      status
      get :index, profile_id: subject.slug
      assigns(:products).should == [product2, product]
    end

    context 'with a specific category' do
      let(:product2) { create :product, user_id: subject.id, name: 'testtest', category_id: subcategory.id }
      let(:category) { create :category }
      let(:subcategory) { create :category, main_category_id: category.id }
      
      it 'assigns products' do
        subcategory
        product
        status
        get :index, profile_id: subject.slug, category: category.slug
        assigns(:products).should == [product2]
      end
    end

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
      let(:category) { create :category }

      it "redirect to edit" do
        post :create, profile_id: subject.slug, product: {"name" => "testtest", "description" => "Great product for a golden test", 'dpt' => '78', "price" => 1, "category_id" => category.id }
        expect(response).to redirect_to edit_product_path(Product.last.slug)
      end
    end
  end

  describe 'GET #show' do
    let(:product) { create :product, user_id: subject.id}
    let(:user2) { create :user }

    it 'return 200' do
      get :show, { id: product.slug }
      expect(response.code).to eq('200')
    end

    it 'assign product' do
      get :show, { id: product.slug }
      expect(assigns(:product)).to eq(product)
    end

    it 'assign status to nil' do
      get :show, { id: product.slug }
      expect(assigns(:status)).to eq(nil)
    end
    
    context 'with already a conversation' do

      context 'when the current user is not the owner' do
        let(:product) { create :product, user_id: user2.id}
        let(:status) { create :status, product_id: product.id, user_id: subject.id}
        let(:message) { create :message, sender_id: subject.id, receiver_id: user2.id, status_id: status.id }

        it 'assign status' do
          message
          get :show, { id: product.slug }
          expect(assigns(:status)).to eq(status)
        end
      end
    end
  end


  describe 'GET #edit' do
    let(:product) { create :product, user_id: subject.id}
    let(:product2) { create :product, user_id: user2.id}

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
    let(:product) { create :product, user_id: subject.id}
    let(:product2) { create :product, user_id: user2.id}

    context 'update my product' do
      context 'with correct parameters' do
        it 'update product' do
          put :update, { id: product.id, product: {name: "Great thing", description: "SO Great!"} }
          product.reload
          product.name.should == "Great thing"
          product.slug.should == "#{product.id}-great-thing"
        end

        it 'assign product' do
          put :update, { id: product.id, product: {name: "Great thing", description: "SO Great!"} }
          expect(assigns(:product)).to eq(product)
        end

        it 'redirect_to #show' do
          put :update, { id: product.id, product: {name: "Great thing", description: "SO Great!"} }
          response.should redirect_to product_path(product.reload.slug)
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
      end
    end
  end


  describe 'DELETE #destroy' do
    let(:product) { create :product, owner: subject}
    let(:product2) { create :product, owner: user2}

    context 'with my product' do
      it 'destroy the product' do
        product
        delete :destroy, { id: product.id }
        Product.exists?(product.id).should == false
      end

      it 'redirect_to my product' do
        product
        delete :destroy, { id: product.id }
        expect(response).to redirect_to profile_products_path(subject.slug)
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
end
