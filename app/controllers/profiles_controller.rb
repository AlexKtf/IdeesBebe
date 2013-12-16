class ProfilesController < ApplicationController

  load_resource :user, find_by: :slug, id_param: :id
  load_and_authorize_resource :profile, through: :user, singleton: true

  before_action lambda { authorized_upload(profile_params[:asset_attributes][:file]) if profile_params[:asset_attributes].present? }, only: :update

  # GET /profiles/1
  def show
  end

  # GET /profiles/1/edit
  def edit
    @asset = @profile.has_avatar? ? @profile.asset : @profile.build_asset 
  end

  # PATCH/PUT /profiles/1
  def update
    if @profile.update(profile_params)
      flash[:notice] = I18n.t('profile.update.success')
      redirect_to edit_profile_path(@user.slug)
    else
      render :edit
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
      params.require(:profile).permit(:first_name, :last_name, asset_attributes: [:file])
    end
end
