class ForgottenEmailController < ApplicationController
  def new
    @teams = @current_tournament.teams if @current_tournament
  end

  def show
    @team = Team.find(params[:team][:id])
    @found_user = @team.administrators.detect do |user|
      User.authenticate(user.email, params[:password])
    end

    unless @found_user
      flash[:error] = "Incorrect password"
      return redirect_to new_forgotten_email_path
    end
  end
end
