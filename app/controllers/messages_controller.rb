class MessagesController < ApplicationController

  authorize_resource :message
  load_resource :product

  def create
    status = @product.status.create!(user_id: current_user.id) if message_params[:status_id].nil?
    message = status.messages.build(message_params.merge(sender_id: current_user.id))
    if message.save
      flash[:notice] = I18n.t('message.create.success')
    elsif message.errors.any?
      flash[:error] = message.errors.first[1]
    else
      flash[:error] = I18n.t('message.create.error')
    end
    
    redirect_to :back
    rescue ActionController::RedirectBackError
      redirect_to product_path(@product.slug)
  end

  private

    def message_params
      params.require(:message).permit(:content, :receiver_id, :status_id)
    end
end
