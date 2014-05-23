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

  def new_message_for(receiver, message)
    @message = message
    @receiver = receiver
    @subject = I18n.t('notifier.new_message_for.subject')
    mail(
      from: "Idees Bebe <#{@message.sender.slug}@user.colamaya.com>",
      to: @receiver.email,
      subject: @subject
    )
  end

  def signalized_as_buyer(user, product)
    @user = user
    @product = product
    mail(
      from: 'Idees Bebe <#product.owner.slug}@user.dev-ideesbebe.com>',
      to: @user.email,
      subject: I18n.t('notifier.signalized_as_buyer.subject', product: @product.name)
    )
  end

  def product_not_available_anymore(users, product)
    first_user = users.shift
    @product = product
    @subject = I18n.t('notifier.product_not_available_anymore.subject', product: @product.name)
    mail(
      from: 'Idees Bebe <#product.owner.slug}@user.dev-ideesbebe.com>',
      to: first_user,
      bcc: users,
      subject: @subject
    )
  end

  def admin_need_to_check product
    @product = product
    @subject = I18n.t('notifier.admin_need_to_check.subject', product: @product.name)
    mail(
      from: 'Idees Bebe <administration@user.dev-ideesbebe.com>',
      to: User.where(is_admin: true).pluck(:email),
      subject: @subject
    )
  end

  def reminder(message, time)
    return false if not message.need_to_remember?
    @message = message
    @subject = I18n.t("notifier.reminder_#{time}_days.subject")
    @user = message.sender
    mail(
      to: @message.receiver.email,
      subject: @subject
    )
  end
end
