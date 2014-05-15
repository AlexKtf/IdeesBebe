class CategoriesController < ApplicationController

  load_and_authorize_resource :category, find_by: :slug, id_param: :id, only: :show
  load_and_authorize_resource :category, find_by: :slug, id_param: :category_id, only: :show_subcategory

  def show
    @products = @category.all_products.avalaible.page(params[:page])
  end

  def show_subcategory
    @subcategory = @category.subcategories.find_by_slug(params[:id])
    @products = @subcategory.all_products.avalaible.page(params[:page])
  end
end
