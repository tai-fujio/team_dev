class AgendaDeletedNotifyMailer < ApplicationMailer
  default from: 'from@example.com'

  def agenda_deleted_notify(agenda,email)
    @agenda = agenda
    @email = email
    mail to: @email, subject: I18n.t('views.messages.agenda_deleted_notify')
  end
end
