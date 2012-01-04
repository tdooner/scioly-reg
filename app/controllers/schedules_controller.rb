class SchedulesController < ApplicationController
	####
	# A "schedule" means a "scheduled event" for a given
	# tournament and division. In other words, a "schedule"
	# is what a team registers to.
	###

  before_filter :is_admin, :only => [:new, :destroy]
  protect_from_forgery :except => :destroy
  autocomplete :schedule, :event, :display_value => :humanize, :extra_data => [:division]

  def new
	  breadcrumbs.add("New Event")
	  @schedule = Schedule.new()
  end

  def create
	@schedule = @current_tournament.schedules.create(params[:schedule])
	if @schedule 
      if params[:schedule_online] == "true"
        @schedule.updateTimeSlots()
      end
      redirect_to :schedules
	else
      flash[:message] = "Error creating the event schedule. "
      flash[:error] = @schedule.errors.full_messages.first
      render :new
	end
  end

  def index
	breadcrumbs.add('Register For Events')
    if not @team.nil?
		@has_registered = Hash.new()
		@all_schedules.map{ |x| @has_registered[x.id] = x.hasTeamRegistered(@team)}
    end
	render :list
  end

  def show
	breadcrumbs.add('Register For Events', schedules_url)
	@schedule = Schedule.find(params[:id])
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
			@signed_up_teams = @schedule.timeslots.map {|x| x.sign_ups.map{ |y| y.team } }.flatten.to_set
			@teams_remaining = Team.find(:all, :conditions => ["division = ?", @schedule.division], :order => ["name ASC"]).to_set.difference(@signed_up_teams)
			render :pdf => @schedule.event.gsub(/[^a-zA-Z]/, '_') + "_" + @schedule.division
		end
		format.html do
          render :show
		end
	end
  end

  def destroy
	@schedule = Schedule.find(params[:id])
	@schedule.timeslots do |e|
		e.sign_ups.delete_all()
		e.delete()
	end
	@schedule.delete()
	redirect_to :schedules
  end
end
