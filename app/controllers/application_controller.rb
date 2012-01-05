class ApplicationController < ActionController::Base
  protect_from_forgery
  before_filter :setup

  def setup
	breadcrumbs.add 'Home', root_path
    
    @mixpanel = Mixpanel::Tracker.new(ENV["MIXPANEL_TOKEN"], request.env, true)

	@current_tournament = Tournament.get_current()
    @team = Team.find_by_id_and_tournament_id(session[:team], @current_tournament)
	@all_schedules = @current_tournament.schedules.find(:all, :order => "event ASC").group_by(&:division)
	
	if @team 
		@dont_forget = SignUp.getTeamUnregistered(@team)
	end

    @dont_forget ||= nil
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

class Breadcrumbs::Render::Bootstrap < Breadcrumbs::Render::Base
  def render
    str = ""
    breadcrumbs.items.each_with_index do |item, i| 
      str << render_item(item, i)
    end
    return "<ul class='breadcrumb'>#{str}</ul>"
  end

  def render_item(item, i)
    if item[1] != nil
      return "<li><a href='#{item[1]}'>#{item[0]}</a><span class='divider'>/</span></li>"
    else
      return "<li>#{item[0]}</li>"
    end
  end
end

