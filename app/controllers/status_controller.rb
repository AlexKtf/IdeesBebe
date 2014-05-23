class StatusController < ApplicationController
  # Routes for show, update needs product.slug and status user slug
  authorize_resource :status
  
  load_resource :product
  load_resource :user, find_by: :slug, id_param: :id

  def show
    raise CanCan::AccessDenied unless current_user.is_owner_of? @product or current_user == @user
    @status = Status.find_by(user_id: @user.id, product_id: @product.id)
    @receiver = current_user.is_owner_of?(@product) ? @status.user : @product.owner
    @messages = @status.messages.order(:created_at)
  end

  def update
    raise CanCan::AccessDenied unless current_user.is_owner_of? @product or @product.selled_to == current_user

    @status = Status.find_by(user_id: @user.id, product_id: @product.id)
    @status.update(status_params)
    respond_to do |format|
      format.html do
        redirect_to product_status_path(@product.slug, @status.user.slug)
      end
      format.js
    end
  end

  private

    def status_params
      params.require(:status).permit(:closed, :done, :satisfied)      
    end
end
