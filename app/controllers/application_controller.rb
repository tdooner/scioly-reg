class ApplicationController < ActionController::Base
  protect_from_forgery
  before_filter :setup

  def setup
	breadcrumbs.add 'Home', root_path

	@current_tournament = Tournament.get_current()
	@all_schedules = Schedule.find(:all, :order => "event ASC")

	if not session[:team].nil?
		@dont_forget = SignUp.getTeamUnregistered(session[:team])
	end
  end
end
