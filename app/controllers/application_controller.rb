class ApplicationController < ActionController::Base
  protect_from_forgery
  before_filter :setup

  def setup
    breadcrumbs.add 'Home', root_path

    @subdomain = request.env["SERVER_NAME"].split(".").first
    @mixpanel = Mixpanel::Tracker.new(ENV["MIXPANEL_TOKEN"], request.env, true)

    @current_school = School.find_by_subdomain(@subdomain) or raise "School (#{@subdomain}) Not Found!"
    @current_tournament = @current_school.tournaments.find(:first, :conditions => ["school_id = ? AND is_current = ?", @current_school.id, true]) or raise "No Tournament Found!"
    @team = Team.find_by_id_and_tournament_id(session[:team], @current_tournament)
    @all_schedules = @current_tournament.schedules.find(:all, :order => "event ASC").group_by(&:division)
    @all_schedules["B"] ||= []
    @all_schedules["C"] ||= []
    
    if @team 
      @dont_forget = @team.unregistered_events
    end

    @dont_forget ||= nil
  end

  def is_admin
    if session[:user].nil?
      redirect_to :root
      return
    end
    if not session[:user].is_admin_of(@current_school)
      redirect_to :root
      session.delete(:user)
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

