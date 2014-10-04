class UserMailer < ActionMailer::Base
  default :from => 'sciolyreg.org <no-reply@sciolyreg.org>',
    :return_path => 'no-reply@sciolyreg.org'
  layout 'email'

  def forgot_password(user:, reset_token:)
    @tournament = Tournament.first # HACK. TODO: Make a school-agnostic template

    @user = user
    @reset_token = reset_token

    mail(:to => user.email,
         :subject => 'Science Olympiad Registration Password Reset')
  end
end
