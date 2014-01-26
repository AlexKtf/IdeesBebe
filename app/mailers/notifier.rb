class Notifier < ActionMailer::Base
  default from: 'Idees Bebe <support@dev-ideesbebe.com>'

  def welcome user
    @user = user
    @subject = I18n.t('notifier.welcome.subject')
    mail(
      to: @user.email,
      subject: @subject
    )
  end

  def new_message message
    @message = message
    @product = message.product
    @subject = message.from_seller? ? I18n.t('notifier.new_message.from_seller.subject') : I18n.t('notifier.new_message.from_buyer.subject')
    mail(
      from: "Idees Bebe <#{@message.sender.slug}.#{@product.id}@user.dev-ideesbebe.com>",
      to: @message.receiver.email,
      subject: @subject
    )
  end
end
