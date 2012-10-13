class Admin::ScorecenterController < ApplicationController
  before_filter :is_admin
  before_filter :ensure_json_makes_sense
  protect_from_forgery :only => []

  caches_action :scores

  def index
    breadcrumbs.add("Scoring Center", "#")
    # Todo: Filter out unneeded information from here.
    @data = @current_tournament.schedules.includes({ :scores => :team }).to_json(:include => { :scores => { :include => :team }})
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
    score = Score.find_or_initialize_by_schedule_id_and_team_id(params[:event_id], params[:team_id])
    score.placement = params[:placement]
    score.save()

    render :json => { :placement => score.reload.placement }
  end

private

  def ensure_json_makes_sense
    ActiveRecord::Base.include_root_in_json = false # TODO Move to initializer
  end
end
