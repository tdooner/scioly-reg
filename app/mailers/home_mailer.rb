class HomeMailer < ActionMailer::Base
  default :from => 'Foundry <no-reply@sciolyreg.org>',
    :bcc => 'tomdooner@gmail.com',
    :return_path => 'no-reply@sciolyreg.org'
  layout 'email'

  def welcome(tournament)
    @tournament = tournament

    mail(:to => @tournament.school.admin_email)
  end
end
