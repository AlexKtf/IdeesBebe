class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.

  protect_from_forgery with: :exception

  before_filter :configure_permitted_parameters, if: :devise_controller?
  before_filter :stored_location, if: :devise_controller?

  rescue_from CarrierWave::DownloadError, with: :carrierwave_download_error
  rescue_from CarrierWave::IntegrityError, with: :carrierwave_integrity_error

  rescue_from CanCan::AccessDenied do |exception|
    redirect_to forbidden_path
  end

  def after_sign_in_path_for resource
    session[:stored_location] || root_path
  end

  protected

    def stored_location
      session[:stored_location] ||= request.referrer if params[:action].to_sym == :new
    end

    def configure_permitted_parameters
      devise_parameter_sanitizer.for(:sign_in) { |u| u.permit(:username, :email, :password) }
      devise_parameter_sanitizer.for(:sign_up) { |u| u.permit(:username, :email, :password, :password_confirmation) }
    end

    def carrierwave_download_error
      flash[:alert] = I18n.t('upload.error.download')
      redirect_to :back
    end

    def carrierwave_integrity_error
      flash[:alert] = I18n.t('upload.error.integrity')
      redirect_to :back
    end
end
