require 'spec_helper'

describe CategoriesController do
  let(:user){ FactoryGirl.create :user }
  let(:category) { FactoryGirl.create :category, main_category_id: main.id }
  let(:main) { FactoryGirl.create :category }
  let(:product) { FactoryGirl.create :product, name: "lol", owner: user, category_id: category.id }

  describe '#show' do

    it 'assigns @category' do
      product
      get :show, { id: main.slug }
      assigns(:category).should == main
    end

    it 'assigns @products' do
      product
      get :show, { id: main.slug }
      assigns(:products).should_not be_empty
    end

    it 'render show template' do
      product
      get :show, { id: main.slug }
      response.should render_template :show
    end
  end

  describe '#show_subcategory' do

    it 'assigns @category' do
      product
      get :show_subcategory, { category_id: main.slug, id: category.slug }
      assigns(:category).should == main
    end

    it 'assigns @subcategory' do
      product
      get :show_subcategory, { category_id: main.slug, id: category.slug }
      assigns(:subcategory).should == category
    end

    it 'assigns @products' do
      product
      get :show_subcategory, { category_id: main.slug, id: category.slug }
      assigns(:products).should_not be_empty
    end

    it 'render show_subcategory template' do
      product
      get :show_subcategory, { category_id: main.slug, id: category.slug }
      response.should render_template :show_subcategory
    end
  end
end