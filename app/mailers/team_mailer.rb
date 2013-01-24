class TeamMailer < ActionMailer::Base
  default :from => 'sciolyreg.org <no-reply@sciolyreg.org>',
    :return_path => 'no-reply@sciolyreg.org'
  layout 'email'

  def password_update(team, password)
    @tournament = team.tournament

    @team = team
    @password = password

    mail(:to => team.email,
         :subject => "Science Olympiad Registration Password - #{team.tournament.title}")
  end
end
