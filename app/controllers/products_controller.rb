class ProductsController < ApplicationController
  load_resource :user, find_by: :slug, id_param: :profile_id, only: [:index, :new]

  load_and_authorize_resource :product, shallow: true, only: [:show, :new, :edit, :update, :destroy]

  def index
    if params[:category].present?
      @main_category = Category.find_by_slug(params[:category])
      @products = current_user.products.order('created_at DESC').where(category_id: @main_category.subcategories.pluck(:id))
    else
      @products = current_user.products.order('created_at DESC')
    end
  end
  
  # GET /products/1
  def show
    @comment = Comment.new
    @status = @product.status.find_by(user_id: current_user.id) if user_signed_in? and not current_user.is_owner_of? @product
    @user = @product.owner
  end

  # GET /profiles/:profile_id/products/new
  def new
    raise CanCan::AccessDenied.new('Not authorized!') if @user != current_user
  end

  # GET /products/1/edit
  def edit
  end

  # POST /profiles/:profile_id/products
  def create
    @product = current_user.products.build(product_params)
    if @product.save
      redirect_to edit_product_path(@product.slug), notice: I18n.t('product.create.success')
    else
      render action: :new
    end
  end

  # PATCH/PUT /products/1
  def update
    if @product.update(product_params)
      redirect_to edit_product_path(@product.slug), notice: I18n.t('product.update.success')
    else
      @cat = @product.category_id_was
      render action: :edit
    end
  end

  # DELETE /products/1
  def destroy
    if @product.destroy
      flash[:notice] = I18n.t('product.destroy.success')
    else
      flash[:alert] = I18n.t('product.destroy.error')
    end
    redirect_to profile_products_path(@product.owner.slug)
  end

  private

    def product_params
      params.require(:product).permit(:name, :price, :description, :category_id)
    end
end
