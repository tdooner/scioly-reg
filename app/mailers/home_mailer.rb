class HomeMailer < ActionMailer::Base
  default :from => 'Foundry <no-reply@sciolyreg.org>',
    :return_path => 'no-reply@sciolyreg.org'

  def welcome(to_email)
    mail(:to => 'tomdooner@gmail.com')
  end
end
