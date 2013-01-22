class HomeMailer < ActionMailer::Base
  default :from => 'Foundry <no-reply@sciolyreg.org>',
    :return_path => 'no-reply@sciolyreg.org'
  layout 'email'

  def welcome(tournament)
    @tournament = tournament

    mail(:to => 'tomdooner@gmail.com')
  end
end
