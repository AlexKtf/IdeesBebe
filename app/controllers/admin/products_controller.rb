class Admin::ProductsController < Admin::BaseController

  def index
    products = Product.all.includes(:owner, :photos).order('updated_at DESC')

    if params[:allowed].present? and not params[:allowed] == 'undefined'
      if params[:allowed] == 'null'
        products = products.where(allowed: nil)
      else
        products = products.where(allowed: params[:allowed])
      end
    end

    respond_to do |format|
      format.html
      format.json { render json: products, include: [:owner, :photos] }
    end
  end
end
