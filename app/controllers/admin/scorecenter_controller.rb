class Admin::ScorecenterController < ApplicationController
  before_filter :is_admin
  before_filter :ensure_json_makes_sense
  protect_from_forgery :only => []

  caches_action :scores

  def index
    breadcrumbs.add("Scoring Center", "#")
    @schedules = @current_tournament.schedules
    @teams = @current_tournament.teams
  end

  def events
    render :json => @current_tournament.schedules
  end

  def scores
    @schedule = Schedule.find(params[:id])
    @teams = Team.where({ 
      :division => @schedule.division,
      :tournament_id => @schedule.tournament_id 
    }).includes(:scores)
    @teams_with_scores = @teams.sort_by{|x| x.name}.map do |team| 
      ranking = team.scores.select{|x| x.schedule_id == @schedule.id}.first
      { 
        :team => team, 
        :ranking => ranking || Score.new({ :team => team, :schedule => @schedule })
      }
    end
    render :json => @teams_with_scores
  end

  def update_event
    score = Score.find_or_initialize_by_schedule_id_and_team_id(params[:id], params[:team_id])
    score.placement = params[:ranking][:placement]
    score.save()

    render :json => { 
      :team => score.team,
      :ranking => score.reload()
    }
  end

  private

  def ensure_json_makes_sense
    ActiveRecord::Base.include_root_in_json = false # TODO Move to initializer
  end
end
