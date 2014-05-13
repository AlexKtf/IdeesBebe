class PhotosController < ApplicationController

  load_and_authorize_resource :photo, except: :create
  load_resource :product, only: :create

  def create
    raise CanCan::AccessDenied if @product.owner != current_user
    @asset = @product.photos.build(asset_params)
    if not @asset.file? or not @asset.valid?
      flash[:alert] = I18n.t('asset.file.non-valid')
    elsif @asset.save!
      flash[:notice] = I18n.t('asset.create.success')
    else
      flash[:alert] = I18n.t('asset.create.error')
    end

    respond_to do |format|
      format.html { redirect_to edit_product_path(@product.slug) }
      format.js do
        if flash and not flash[:alert].empty?
          render js: "window.location = '#{edit_product_path(@product.slug)}'"
        else
          @index = params[:index]
        end
      end
    end
  end

  # PUT /photo/1
  def update
    if @photo.update(asset_params)
      flash[:notice] = I18n.t('asset.become_starred.success')
    else
      flash[:alert] = I18n.t('asset.become_starred.error')
    end
    redirect_to edit_product_path(@photo.product.slug)
  end

  # DELETE /photo/1
  def destroy
    if @photo.destroy
      flash[:notice] = I18n.t('asset.destroy.success')
    else
      flash[:alert] = I18n.t('asset.destroy.error')
    end
    redirect_to edit_product_path(@photo.product.slug)
  end

  private

    def asset_params
      params.require(:photo).permit(:file, :starred)
    end
end
