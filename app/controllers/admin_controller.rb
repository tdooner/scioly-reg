class AdminController < ApplicationController
  before_filter :is_admin

  def index
    breadcrumbs.add("Admin Panel")
    @teams = @current_tournament.teams

    @signups = SignUp.all
  end

  def scores
    breadcrumbs.add("Scoring")

    @events = @current_tournament.schedules.includes(:scores)
  end

  def scoreslideshow
    breadcrumbs.add("Scoring", admin_scores_url)
    breadcrumbs.add("Slideshow")
    @teams = @current_tournament.teams
    @events = @current_tournament.schedules.includes(:scores)
    @unfinishedevents = @events.select{|x| x.scores.empty?}
    @withheldevents = @events.select{|x| x.scores_withheld?}
  end

  def scorespublish
    @events = @current_tournament.schedules.includes(:scores)
    @unfinishedevents = @events.select{|x| x.scores.empty?}
    @withheldevents = @events.select{|x| x.scores_withheld?}
  end
end
