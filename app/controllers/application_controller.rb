class ApplicationController < ActionController::Base
  protect_from_forgery
  before_filter :setup

  def setup
	breadcrumbs.add 'Home', root_path

	@current_tournament = Tournament.get_current()
    @team = Team.find_by_id_and_tournament_id(session[:team], @current_tournament)
    @team ||= nil
	
	if @team 
		@dont_forget = SignUp.getTeamUnregistered(@team)
		@all_schedules = @current_tournament.schedules.find(:all, :conditions => ["division = ?", @team.division], :order => "event ASC")
	else
		@all_schedules = @current_tournament.schedules.find(:all, :order => "event ASC")
	end
  end

  def is_admin
	  if session[:user].nil?
		  redirect_to :root
		  return
	  end
	  if not User.is_admin(session[:user])
			  redirect_to :root
			  return
	  else
			  breadcrumbs.add("Admin", admin_index_url)
	  end
  end
end

