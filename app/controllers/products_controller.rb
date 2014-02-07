class ProductsController < ApplicationController
  load_resource :user, find_by: :slug, id_param: :profile_id, only: [:index, :new]
  load_and_authorize_resource :product, find_by: :slug, shallow: true, except: [:index, :by_category, :update, :create, :destroy]

  load_and_authorize_resource :product, find_by: :id, shallow: true, only: [:update, :destroy]

  def index
  end
  
  # GET /products/1
  def show
    @comment = Comment.new
    if not current_user.is_owner_of? @product
      @message = @product.last_message_with(current_user)
    end
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
      redirect_to product_path(@product.slug), notice: I18n.t('product.create.success')
    else
      render action: :new
    end
  end

  # PATCH/PUT /products/1
  def update
    if @product.update(product_params)
      redirect_to edit_product_path(@product.slug), notice: I18n.t('product.update.success')
    else
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
    redirect_to products_path(@product.owner.slug)
  end

  private

    def product_params
      params.require(:product).permit(:name, :description, :category_id)
    end
end
