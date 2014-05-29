class MessagesController < ApplicationController

  authorize_resource :message
  load_resource :product, only: :create
  load_resource :user, find_by: :slug, id_param: :profile_id, only: :index

  def index
    raise CanCan::AccessDenied if @user != current_user
    @state = params[:state]
    @status = (@user.try("#{@state}_status") || @user.status).order('statuses.updated_at DESC')
  end

  def create
    status = message_params[:status_id].present? ? Status.find(message_params[:status_id]) : @product.status.build(user_id: current_user.id)
    status.save! if current_user.messages_sent.build(message_params).valid?
    message = status.messages.build(message_params.merge(sender_id: current_user.id))

    if message.save
      flash[:notice] = I18n.t('message.create.success')
    elsif message.errors.any?
      flash[:alert] = message.errors.first[1]
    else
      flash[:alert] = I18n.t('message.create.error')
    end

    respond_to do |format|
      format.html do
        begin
          redirect_to :back
        rescue ActionController::RedirectBackError
          redirect_to product_path(@product.slug)
        end
      end
      format.js do
        flash.clear
        @message = message
        @status = status
      end
    end    
  end

  private

    def message_params
      params.require(:message).permit(:content, :receiver_id, :status_id)
    end
end
