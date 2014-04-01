class Admin::ProductsController < Admin::BaseController

  def index
    respond_to do |format|
      format.html
      format.json { render json: Product.all.order('updated_at DESC'), include: [:owner, :photos] }
    end
  end
end
