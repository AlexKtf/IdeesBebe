class ProfilesController < ApplicationController

  load_resource :user, find_by: :slug, id_param: :id
  load_and_authorize_resource :profile, through: :user, singleton: true

  # GET /profiles/1
  def show
    @products = @user.products.includes(:category).page(params[:page])
  end

  # GET /profiles/1/edit
  def edit
  end

  # PATCH/PUT /profiles/1
  def update

    respond_to do |format|
      format.html do
        if profile_params[:avatar].present? and Photo.new(file: profile_params[:avatar]).valid?
          flash[:alert] = I18n.t('upload.error.integrity')
          redirect_to edit_profile_path(@user.slug)
        elsif @profile.update(profile_params)
          flash[:notice] = I18n.t('profile.update.success')
          redirect_to profile_path(@user.slug)
        else
          render :edit
        end
      end
      format.js do
        if Photo.new(file: profile_params[:avatar]).valid?
          @profile.update!(profile_params)
        else
          flash[:alert] = I18n.t('upload.error.integrity')
          render js: "window.location = '#{edit_profile_path(@user.slug)}'"
        end
      end
    end
  end

  # DELETE /profiles/1
  def destroy
    if @user.destroy
      flash[:notice] = I18n.t('profile.destroy.success')
    else
      flash[:alert] = I18n.t('profile.destroy.error')
    end
    redirect_to root_url
  end

  private

    def profile_params
      params.require(:profile).permit(:first_name, :last_name, :avatar, :remove_avatar)
    end
end
