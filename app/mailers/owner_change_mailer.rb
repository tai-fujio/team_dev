class OwnerChangeMailer < ApplicationMailer
  default from: 'from@example.com'
  def owner_change_notification(email,team)
    @email = email
    @team = team
    mail to: @email, subject: I18n.t('views.messages.owner_delegation_notification')
  end
end
