class ApplicationController < ActionController::Base
  protect_from_forgery
  before_filter :setup

  def setup
    @subdomain = request.subdomains.last
    @mixpanel = Mixpanel::Tracker.new(ENV["MIXPANEL_TOKEN"], env: request.env)
    @current_admin = User.find(session[:user_id]) if session[:user_id]

    if @subdomain.present?
      @current_school = School.where(:subdomain => @subdomain).first
      setup_application if @current_school
    end
  end

  def setup_application
    breadcrumbs.add 'Home', root_path

    @current_tournament = @current_school
                            .tournaments
                            .where(is_current: true)
                            .includes(:schedules)
                            .first or raise "No Tournament Found!"

    @team = Team.where(id: session[:team], tournament_id: @current_tournament)
                .includes(tournament: { schedules: :timeslots },
                          sign_ups: { timeslot: :schedule })
                .first if session[:team]

    schedules_scope = @current_tournament.schedules
    schedules_scope = schedules_scope.includes(timeslots: :sign_ups) if @team

    @all_schedules = Hash.new([])
    @all_schedules.merge!(schedules_scope.group_by(&:division))

    @is_admin = !!@current_admin.try(:is_admin_of, @current_school)

    if @team
      @dont_forget = @team.unregistered_events
    end

    @dont_forget ||= nil

    Time.zone = @current_school.time_zone
  end

  def is_admin
    if !@is_admin
      redirect_to :root
      session.delete(:user)
      return
    else
      breadcrumbs.add("Admin", admin_index_url)
    end
  end

  def team_logged_in
    unless @team
      session.delete(:team)
      redirect_to :root
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
