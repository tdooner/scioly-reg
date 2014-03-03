class SchedulesController < ApplicationController
  ####
  # A "schedule" means a "scheduled event" for a given
  # tournament and division. In other words, a "schedule"
  # is what a team registers to.
  ###

  before_filter :is_admin, :only => [:new, :destroy, :batchnew, :edit, :create, :update, :scores, :savescores, :batchcreate, :all_pdfs]
  protect_from_forgery :except => :destroy

  def index
    breadcrumbs.add('Register For Events')
    if not @team.nil?
      @has_registered = Hash.new()
      @all_schedules[@team.division].map{ |e| @has_registered[e.id] = e.hasTeamRegistered(@team)}
    end
  end

  # TODO: Move the pdf logic to Admit::SchedulesController
  def show
    @schedule = Schedule.find(params[:id])
    breadcrumbs.add("Division #{@schedule.division} Events", division_schedules_url(@schedule.division))
    @scores = @schedule.scores.includes(team: :tournament)
    breadcrumbs.add(@schedule.event)
    if @schedule.nil?
      flash[:message] = "Event not found!"
      # render :somethingelse
    end

    @allslots = @schedule.timeslots.sort { |x,y| x.begins <=> y.begins }
    @currentreg = nil
    if @team
      @currentreg = SignUp.find_by_team_id_and_timeslot_id(@team, @allslots.map{|x| x.id})
    end

    respond_to do |format|
      format.pdf do
        if !@is_admin
          flash[:error] = 'You must be a tournament administrator to download event registration PDFs. Please contact the tournament director if you need a PDF for yourself.'
          redirect_to schedule_url(@schedule)
        end

        render :pdf => @schedule.event.gsub(/[^a-zA-Z]/, '_') + "_" + @schedule.division
      end
      format.html do
        render :show
      end
    end
  end

  def scores
    @schedule = Schedule.find(params[:schedule_id], :include => :scores)
    @teams = @current_tournament.teams.where("division = ?", @schedule.division).includes(:tournament)
    @placements = @teams.inject({}) { |a,i|
      s = @schedule.scores.select{|x| x.team_id == i.id}.first
      if s
        a.merge(i.id => s.placement)
      else
        a.merge(i.id => "")
      end
    }
    breadcrumbs.add("Scoring", "/admin/scores")
    breadcrumbs.add(@schedule.humanize)
  end
end
